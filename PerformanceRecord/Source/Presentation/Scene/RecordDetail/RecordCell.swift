//
//  RecordCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//


import UIKit
import SnapKit

final class RecordCell: SwipableCell {
    
    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private let photoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()

    // 사진을 표시할 컬렉션뷰
    private lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    
    // MARK: - Properties
    private var recordDetailUIModel: RecordDetailUIModel? = nil
    var onPhotoTapped: ((UIImage?) -> Void)? // 사진 탭 이벤트를 전달할 클로저

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isLeftSwipeEnable = true
        isRightSwipeEnable = true
        
        setupUI()
        setupLayout()
        photoCollectionView.delegate = self // 델리게이트 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        recordDetailUIModel = nil
        onPhotoTapped = nil
        
        dateLabel.text = nil
        ratingLabel.text = nil
        memoLabel.attributedText = nil
        photoTitleLabel.text = nil
        photoCollectionView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        mainStackView.addArrangedSubview(dateLabel)
        mainStackView.addArrangedSubview(ratingLabel)
        mainStackView.addArrangedSubview(memoLabel)
        mainStackView.addArrangedSubview(photoTitleLabel)
        mainStackView.addArrangedSubview(photoCollectionView)
        
        swipeableView.backgroundColor = .systemBackground
        swipeableView.addSubview(mainStackView)
    }
    
    private func setupLayout() {
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        photoCollectionView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
    }
    
    // MARK: - Public Methods

    func configure(with uiModel: RecordDetailUIModel) {
        self.recordDetailUIModel = uiModel
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        dateLabel.text = formatter.string(from: uiModel.record.viewedAt)
        
        ratingLabel.text = "⭐️ \(uiModel.record.rating)"
        
        // 메모가 있으면 표시하고, 없으면 숨김
        let reviewText = uiModel.record.reviewText
        if !reviewText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let attributedString = NSAttributedString(string: reviewText, attributes: [.paragraphStyle: paragraphStyle])
            memoLabel.attributedText = attributedString
            memoLabel.isHidden = false
        } else {
            memoLabel.isHidden = true
        }
        
        // 사진이 있으면 표시하고, 없으면 숨김
        let thumbnails = uiModel.recordImageThumbnails
        photoTitleLabel.isHidden = thumbnails.isEmpty
        photoTitleLabel.text = "📷 사진 (\(thumbnails.count))"
        photoCollectionView.isHidden = thumbnails.isEmpty
        photoCollectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource for PhotoCollectionView
extension RecordCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordDetailUIModel?.recordImageThumbnails.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoCell else {
            return UICollectionViewCell()
        }
        let thumbnail = recordDetailUIModel?.recordImageThumbnails[indexPath.item]
        cell.imageView.image = thumbnail
        return cell
    }
}

// MARK: - UICollectionViewDelegate for PhotoCollectionView
extension RecordCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            guard let recordUIModel = recordDetailUIModel else {
                return
            }
            let imageID = recordUIModel.record.recordImageUUIDs[indexPath.item]
            let originalImage = try await DefaultImageRepository.shared.loadImage(with: imageID, in: .record(id: recordUIModel.record.id))
            onPhotoTapped?(originalImage)
        }
    }
}
