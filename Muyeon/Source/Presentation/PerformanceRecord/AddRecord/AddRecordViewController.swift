//
//  AddRecordViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit
import PhotosUI

class AddRecordViewController: ModalCardViewController {

    // View를 lazy var로 선언 (초기화 시 self 사용)
    private lazy var rootView = AddRecordView(performance: self.performance)

    // 데이터 프로퍼티
    private let performance: Performance
    private var selectedDate: Date = Date()
    private var rating: Double = 5.0
    private var imageRecords: [ImageRecord] = []
    
    init(performance: Performance) {
        self.performance = performance
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
        
        setupActions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        view.endEditing(true)
    }

    // View의 클로저들과 Controller의 로직 연결
    private func setupActions() {
        rootView.memoTextView.delegate = self
        rootView.imagesCollectionView.dataSource = self
        
        rootView.onDateChanged = { [weak self] date in
            self?.selectedDate = date
        }
        
        rootView.onRatingChanged = { [weak self] rating in
            self?.rating = Double(rating)
        }
        
        rootView.onAddImageTapped = { [weak self] in
            self?.presentImagePicker()
        }
        
        rootView.onSaveButtonTapped = { [weak self] in
            self?.saveRecord()
        }
    }
    
    // MARK: - Logic
    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5 - imageRecords.count
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
        print("이미지 개수: \(imageRecords.count)")
    }
}

// MARK: - Extensions (Delegate Implementations)
extension AddRecordViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let group = DispatchGroup()
        results.forEach { result in
            group.enter()
            let itemProvider = result.itemProvider
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else { group.leave(); return }
            let assetIdentifier = result.assetIdentifier
            let phAsset = assetIdentifier != nil ? PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier!], options: nil).firstObject : nil
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.imageRecords.append(ImageRecord(image: image, creationDate: phAsset?.creationDate, location: phAsset?.location))
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.rootView.updatePhotoSection(imageCount: self?.imageRecords.count ?? 0)
        }
    }
}

extension AddRecordViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageRecords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddedPhotoCell.identifier, for: indexPath) as? AddedPhotoCell else { return UICollectionViewCell() }
        cell.imageView.image = imageRecords[indexPath.item].image
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.imageRecords.remove(at: indexPath.item)
            self.rootView.updatePhotoSection(imageCount: self.imageRecords.count)
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
