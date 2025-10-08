//
//  AddRecordView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class AddRecordView: UIView {
    
    // MARK: - UI Components
    let memoTextView = UITextView()
    let imagesCollectionView: UICollectionView
    let saveButton = ShrinkableButton()
    
    // MARK: - Actions (Closures)
    var onAddImageTapped: (() -> Void)?
    var onDeleteImage: ((Int) -> Void)?
    
    // MARK: - Private UI Components
    let viewedDatePicker = UIDatePicker()
    private let imageAddBox = UIView()
    let ratingView = StarRatingView()
    
    init(performance: Performance) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        self.imagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        viewedDatePicker.datePickerMode = .date
        viewedDatePicker.minimumDate = performance.startDate
        viewedDatePicker.maximumDate = min(performance.endDate, .now)
        viewedDatePicker.preferredDatePickerStyle = .compact
        viewedDatePicker.locale = Locale(identifier: "ko_KR")
        
        var saveButtonConfig = UIButton.Configuration.filled()
        saveButtonConfig.title = "새 기록 만들기"
        saveButtonConfig.baseBackgroundColor = .Main.primary
        saveButtonConfig.baseForegroundColor = .white
        saveButtonConfig.cornerStyle = .large
        saveButton.configuration = saveButtonConfig
        
        ratingView.setRating(5.0)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        imagesCollectionView.register(AddedPhotoCell.self, forCellWithReuseIdentifier: AddedPhotoCell.identifier)
        setupLayout(with: performance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endEditing(true)
    }
    
    // MARK: - Public Methods
    func updatePhotoSection(imageCount: Int) {
        let hasImages = imageCount > 0
        imagesCollectionView.isHidden = !hasImages
        imageAddBox.isHidden = hasImages
        imagesCollectionView.reloadData()
        
        // 이미지 추가 박스의 레이블 업데이트
        if let label = imageAddBox.subviews
            .compactMap({ $0 as? UIStackView })
            .first?.arrangedSubviews
            .compactMap({ $0 as? UILabel }).first {
            label.text = "이미지 추가 (\(imageCount)/5)"
        }
    }
    
    // MARK: - Layout
    private func setupLayout(with performance: Performance) {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        
        addSubview(scrollView)
        addSubview(saveButton)
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(400)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        contentStackView.snp.makeConstraints { $0.edges.width.equalToSuperview() }
        
        ratingView.snp.contentHuggingHorizontalPriority = 800
        [createPerformanceHeader(with: performance),
         createSection(title: "언제 관람했나요?", content: viewedDatePicker, axis: .horizontal),
         createSection(title: "공연은 어땠나요?", content: ratingView, axis: .horizontal, spacing: 20),
         createSection(title: "메모", content: createMemoView()),
         createSection(title: "사진", content: createPhotoSection())]
            .forEach(contentStackView.addArrangedSubview(_:))
    }
    
    // MARK: - UI Creation Methods
    private func createSection(
        title: String,
        content: UIView,
        axis: NSLayoutConstraint.Axis = .vertical,
        spacing: CGFloat = 10
    ) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, content])
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    private func createPerformanceHeader(with performance: Performance) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.text = performance.name
        
        let venueLabel = UILabel()
        venueLabel.font = .systemFont(ofSize: 15)
        venueLabel.textColor = .secondaryLabel
        venueLabel.text = performance.facilityFullName
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, venueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        let container = UIView()
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)) }
        return container
    }
    
    private func createMemoView() -> UIView {
        memoTextView.font = .systemFont(ofSize: 15)
        memoTextView.backgroundColor = .secondarySystemBackground
        memoTextView.layer.cornerRadius = 10
        memoTextView.isScrollEnabled = false
        memoTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(100)
        }
        return memoTextView
    }
    private func createPhotoSection() -> UIView {
        configureImageAddBox()
        let container = UIView()
        container.addSubview(imageAddBox)
        container.addSubview(imagesCollectionView)
        
        imageAddBox.snp.makeConstraints { $0.edges.equalToSuperview() }
        imagesCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        imagesCollectionView.isHidden = true
        
        return container
    }
    private func configureImageAddBox() {
        imageAddBox.backgroundColor = .secondarySystemBackground
        imageAddBox.layer.cornerRadius = 10
        imageAddBox.layer.borderWidth = 1
        imageAddBox.layer.borderColor = UIColor.systemGray3.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImageTapped))
        imageAddBox.addGestureRecognizer(tapGesture)
        
        let icon = UIImageView(image: UIImage(systemName: "photo"))
        icon.tintColor = .secondaryLabel
        
        let label = UILabel()
        label.text = "이미지 추가 (0/5)"
        label.textColor = .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        
        imageAddBox.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        imageAddBox.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
    }
    
    // MARK: - Actions
    @objc private func addImageTapped() { onAddImageTapped?() }
    
}
