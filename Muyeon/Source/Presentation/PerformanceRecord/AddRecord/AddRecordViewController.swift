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
    
    var errorDescription: String? {
        switch self {
        case .unsupportedImageExtension:
            return "지원하지 않는 이미지 확장자 파일입니다."
        }
    }
}

class AddRecordViewController: ModalCardViewController {
    
    private let rootView: AddRecordView
    private let viewModel: AddRecordViewModel
    
    // 데이터 프로퍼티
    private let performance: Performance
    private var selectedDate: Date = Date()
    private var rating: Double = 5.0
//    private var currentSelectedImage: [ImageRecord] = []
    private var addedImageData = PublishRelay<[(ImageDataForSaving, UIImage)]>()
    private var deleteImageData = PublishRelay<IndexPath>()
    private var currentSelectedImage: [UIImage] = []
    
    private let disposeBag = DisposeBag()
    
    var onDiaryDataChanged: (() -> Void)?
    
    init(performance: Performance) {
        self.performance = performance
        self.rootView = AddRecordView(performance: performance)
        self.viewModel = AddRecordViewModel(
            performance: performance,
            createDiaryUseCase: DefaultCreateDiaryUseCase(
                diaryRepository: DefaultRecordRepository.shared
            )
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(46)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        bind()
        setupActions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func bind() {
        let input = AddRecordViewModel.Input(
            viewedDate: rootView.viewedDatePicker.rx.date.asObservable(),
            ratingInput: rootView.ratingView.rating.asObservable(),
            reviewText: rootView.memoTextView.rx.text.orEmpty.asObservable(),
            addedImageData: addedImageData.asObservable(),
            deleteImageData: deleteImageData.asObservable(),
            saveButtonTapped: rootView.saveButton.rx.tap.asObservable(),
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedImage
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, imageData in
                owner.currentSelectedImage = imageData.map(\.1)
                owner.rootView.imagesCollectionView.reloadData()
                owner.rootView.updatePhotoSection(imageCount: imageData.count)
            })
            .disposed(by: disposeBag)
        
        output.successCreateDiary
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.onDiaryDataChanged?()
                owner.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupActions() {
        rootView.memoTextView.delegate = self
        rootView.imagesCollectionView.dataSource = self
        rootView.onAddImageTapped = { [weak self] in
            self?.presentImagePicker()
        }
    }
    
    // MARK: - Logic
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5 - currentSelectedImage.count
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func saveRecord() {
        let memo = rootView.memoTextView.text
        
        print("--- 저장할 데이터 ---")
        print("공연: \(performance.name)")
        print("관람일: \(selectedDate)")
        print("평점: \(rating)")
        print("메모: \(memo ?? "없음")")
        print("이미지 개수: \(currentSelectedImage.count)")
    }
}

// MARK: - PHPickerViewControllerDelegate
extension AddRecordViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        Task {
            let loadedImageDataList = await loadDataAndImage(from: results)
            addedImageData.accept(loadedImageDataList)
        }
    }
    
    private func loadDataAndImage(from results: [PHPickerResult]) async -> [(ImageDataForSaving, UIImage)] {
        var imageDataArray: [(ImageDataForSaving, UIImage)] = []
        
        await withTaskGroup(of: (ImageDataForSaving, UIImage)?.self) { group in
            for result in results {
                group.addTask {
                    let itemProvider = result.itemProvider
                    // itemProvider가 이미지를 나타낼 수 있는지 확인(UTType.image 사용)
                    guard itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier),
                          itemProvider.canLoadObject(ofClass: UIImage.self)
                    else {
                        return nil
                    }
                    do {
                        let data = try await self.prepareImageData(from: itemProvider)
                        let image = try await itemProvider.loadImage()
                        return (data, image)
                    } catch {
                        print("이미지 데이터를 로드하는 데 실패했습니다: \(error)")
                        return nil
                    }
                }
            }
            
            // group 내의 모든 작업이 완료될 때까지 기다리고, nil이 아닌 결과만 필터링하여 배열에 추가
            for await data in group {
                if let data = data {
                    imageDataArray.append(data)
                }
            }
        }
        
        return imageDataArray
    }
    
    private func prepareImageData(from provider: NSItemProvider) async throws -> ImageDataForSaving {
        let supportedTypes: [UTType] = [.heic, .jpeg, .png, .tiff, .gif, .webP, .bmp]
        guard let supportedType = supportedTypes.first(
            where: { type in provider.hasItemConformingToTypeIdentifier(type.identifier)}
        ) else {
            throw AddRecordError.unsupportedImageExtension
        }
        let data = try await provider.loadDataRepresentation(for: supportedType)
        return ImageDataForSaving(data: data, type: supportedType)
    }
    
}


// MARK: - UICollectionViewDataSource
extension AddRecordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentSelectedImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AddedPhotoCell.identifier,
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

extension AddRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트뷰 높이 자동 조절을 위해 레이아웃 업데이트
        self.view.layoutIfNeeded()
    }
}
