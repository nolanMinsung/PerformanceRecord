//
//  EditRecordViewController.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/23/25.
//

import UIKit

import RxSwift
import RxCocoa

final class EditRecordViewController: UIViewController {
    
    private let rootView: AddRecordView
    private let container: DIContainer
    private let viewModel: EditRecordViewModel
    
    // 데이터 프로퍼티
    private var currentSelectedImage: [UIImage] = []
    
    private let disposeBag = DisposeBag()
    
    var onRecordDataChanged: (() -> Void)?
    
    init(performance: Performance, container: DIContainer, record: Record) {
        self.rootView = AddRecordView(performance: performance)
        self.container = container
        self.viewModel = EditRecordViewModel(
            performance: performance,
            record: record,
            fetchRecordImagesUseCase: container.resolve(type: FetchRecordImagesUseCase.self),
            updateRecordUseCase: container.resolve(type: UpdateRecordUseCase.self)
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
        bind()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func bind() {
        let input = EditRecordViewModel.Input(
            viewedDate: rootView.viewedDatePicker.rx.date.asObservable().startWith(.now),
            ratingInput: rootView.ratingView.rating.asObservable().startWith(5.0),
            reviewText: rootView.memoTextView.rx.text.orEmpty.asObservable().startWith(""),
            saveButtonTapped: rootView.saveButton.rx.tap.asObservable(),
            dismissButtonTapped: rootView.dismissButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.initialSetting
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind(with: self, onNext: { owner, record in
                owner.rootView.viewedDatePicker.date = record.viewedAt
                owner.rootView.ratingView.setRating(record.rating)
                owner.rootView.memoTextView.text = record.reviewText
                owner.rootView.saveButton.setTitle("기록 업데이트하기", for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.recordImage
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, images in
                owner.currentSelectedImage = images
                owner.rootView.imagesCollectionView.reloadData()
                owner.rootView.updatePhotoSection(imageCount: images.count, isCreatingNewRecord: false)
                owner.rootView.saveButton.isEnabled = true
            })
            .disposed(by: disposeBag)
        
        output.successEditingRecord
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
    
}

// MARK: - UICollectionViewDataSource
extension EditRecordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSelectedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AddedPhotoCell.reuseIdentifier,
            for: indexPath
        ) as? AddedPhotoCell else { return UICollectionViewCell() }
        cell.imageView.image = currentSelectedImage[indexPath.item]
        cell.isEditable = false
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension EditRecordViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTempImage = currentSelectedImage[indexPath.item]
        let photoVC = PhotoViewController(image: selectedTempImage)
        present(photoVC, animated: true)
    }
    
}

extension EditRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트뷰 높이 자동 조절을 위해 레이아웃 업데이트
        self.view.layoutIfNeeded()
    }
}

