//
//  AddRecordViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import PhotosUI

import RxSwift
import RxCocoa
import SnapKit

enum AddRecordError: LocalizedError {
    case unsupportedImageExtension
    case dataConvertingToImageFailed
    
    var errorDescription: String? {
        switch self {
        case .unsupportedImageExtension:
            return "지원하지 않는 이미지 확장자 파일입니다."
        case .dataConvertingToImageFailed:
            return "데이터를 이미지로 변환하는 데 실패했습니다."
        }
    }
}

class AddRecordViewController: UIViewController {
    
    private let rootView: AddRecordView
    private let container: DIContainer
    private let viewModel: AddRecordViewModel
    
    // 데이터 프로퍼티
    private let performance: Performance
    private var addedImageData = PublishRelay<[ImageDataForSaving]>()
    private var phPickerSelected = PublishRelay<[PHPickerResult]>()
    private var deleteImageData = PublishRelay<IndexPath>()
    private var currentSelectedImage: [UIImage] = []
    
    private let disposeBag = DisposeBag()
    
    var onRecordDataChanged: (() -> Void)?
    
    init(performance: Performance, container: DIContainer, image: UIImage? = nil) {
        self.performance = performance
        self.rootView = AddRecordView(performance: performance)
        self.container = container
        self.viewModel = AddRecordViewModel(
            performance: performance,
            createRecordUseCase: container.resolve(type: CreateRecordUseCase.self),
            processUserSelectedImageUseCase: container.resolve(type: ProcessUserSelectedImageUseCase.self)
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        setupActions()
        bind()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func bind() {
        let input = AddRecordViewModel.Input(
            viewedDate: rootView.viewedDatePicker.rx.date.asObservable().startWith(.now),
            ratingInput: rootView.ratingView.rating.asObservable().startWith(5.0),
            reviewText: rootView.memoTextView.rx.text.orEmpty.asObservable().startWith(""),
            phPickerSelected: phPickerSelected.asObservable(),
            deleteImageData: deleteImageData.asObservable(),
            saveButtonTapped: rootView.saveButton.rx.tap.asObservable(),
            dismissButtonTapped: rootView.dismissButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedImage
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, images in
                owner.currentSelectedImage = images
                owner.rootView.imagesCollectionView.reloadData()
                owner.rootView.updatePhotoSection(imageCount: images.count)
                owner.rootView.saveButton.isEnabled = true
            })
            .disposed(by: disposeBag)
        
        output.successCreateRecord
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.onRecordDataChanged?()
                owner.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.shouldDismiss
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupDelegates() {
        rootView.imagesCollectionView.dataSource = self
        rootView.imagesCollectionView.delegate = self
    }
    
    private func setupActions() {
        rootView.imageBoxTapGesture.rx.event
            .filter { $0.state == .recognized }
            .bind(
                with: self,
                onNext: { owner, gesture in
                    owner.rootView.saveButton.isEnabled = false
                    owner.rootView.imageAddBox.isHidden = true
                    owner.rootView.imageLoadingIndicator.isHidden = false
                    owner.rootView.imageLoadingIndicator.startAnimating()
                    owner.presentImagePicker()
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - Logic
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5 - currentSelectedImage.count
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.isModalInPresentation = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension AddRecordViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        phPickerSelected.accept(results)
    }
    
}


// MARK: - UICollectionViewDataSource
extension AddRecordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSelectedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AddedPhotoCell.reuseIdentifier,
            for: indexPath
        ) as? AddedPhotoCell else { return UICollectionViewCell() }
        cell.imageView.image = currentSelectedImage[indexPath.item]
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.deleteImageData.accept(indexPath)
        }
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension AddRecordViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTempImage = currentSelectedImage[indexPath.item]
        let photoVC = PhotoViewController(image: selectedTempImage)
        present(photoVC, animated: true)
    }
    
}

extension AddRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트뷰 높이 자동 조절을 위해 레이아웃 업데이트
        self.view.layoutIfNeeded()
    }
}
