//
//  RecordCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//


import UIKit
import SnapKit

class RecordCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
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
        label.font = .systemFont(ofSize: 14, weight: .semibold)
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
    private var photoUUIDs: [String] = []
    var onPhotoTapped: ((UIImage?) -> Void)? // 사진 탭 이벤트를 전달할 클로저

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        setupUI()
        setupLayout()
        photoCollectionView.delegate = self // 델리게이트 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        mainStackView.addArrangedSubview(dateLabel)
        mainStackView.addArrangedSubview(ratingLabel)
        mainStackView.addArrangedSubview(memoLabel)
        mainStackView.addArrangedSubview(photoTitleLabel)
        mainStackView.addArrangedSubview(photoCollectionView)
        
        contentView.addSubview(mainStackView)
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
    func configure(with diary: Record) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        dateLabel.text = formatter.string(from: diary.viewedAt)
        
        ratingLabel.text = "⭐️ \(diary.rating)"
        
        // 메모가 있으면 표시하고, 없으면 숨김
        let reviewText = diary.reviewText
        if !reviewText.isEmpty {
            memoLabel.text = reviewText
            memoLabel.isHidden = false
        } else {
            memoLabel.isHidden = true
        }
        
        // 사진이 있으면 표시하고, 없으면 숨김
        let uuids = diary.diaryImageUUIDs
        if !uuids.isEmpty {
            self.photoUUIDs = uuids
            photoTitleLabel.text = "📷 사진 (\(uuids.count))"
            photoTitleLabel.isHidden = false
            photoCollectionView.isHidden = false
            photoCollectionView.reloadData()
        } else {
            photoTitleLabel.isHidden = true
            photoCollectionView.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDataSource for PhotoCollectionView
extension RecordCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUUIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        // TODO: UUID를 이용해 실제 이미지 로드
        // For now, setting a placeholder color to differentiate cells
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple]
        cell.imageView.backgroundColor = colors[indexPath.item % colors.count]
        cell.imageView.image = UIImage(systemName: ["house", "pencil", "person", "photo.tv"].randomElement()!)
        return cell
    }
}

// MARK: - UICollectionViewDelegate for PhotoCollectionView
extension RecordCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return }
        onPhotoTapped?(cell.imageView.image)
    }
}
