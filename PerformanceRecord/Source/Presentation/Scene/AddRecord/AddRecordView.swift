//
//  AddRecordView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

class AddRecordView: UIView {
    
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentStackView = UIStackView()
    private let ticketView = TicketView()
    let ticketBlurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    let viewedDatePicker = UIDatePicker()
    let ratingView = StarRatingView()
    let memoTextView = UITextView()
    private(set) var imagesCollectionView: UICollectionView!
    let imageAddBox = UIView()
    let imageLoadingIndicator = UIActivityIndicatorView(style: .large)
    let saveButton = BubbleButton()
    let dismissButton = BubbleButton()
    
    // MARK: - Gesture Recognizers
    let imageBoxTapGesture = UITapGestureRecognizer()
    
    init(performance: Performance) {
        super.init(frame: .zero)
        
        setupUIProperties()
        viewedDatePicker.minimumDate = performance.startDate
        viewedDatePicker.maximumDate = min(performance.endDate, .now)
        
        setupHierarchy()
        setupLayoutConstraints()
        setupContentStack(with: performance)
        
        imagesCollectionView.register(AddedPhotoCell.self, forCellWithReuseIdentifier: AddedPhotoCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endEditing(true)
    }
    
}


extension AddRecordView: BaseViewSettings {
    
    func setupUIProperties() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        
        contentStackView.axis = .vertical
        
        ticketView.backgroundColor = .clear
        ticketView.borderWidth = 1.5
        ticketBlurBackground.alpha = 0.7
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        imagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        imagesCollectionView.backgroundColor = .clear
        imagesCollectionView.showsHorizontalScrollIndicator = false
        
        viewedDatePicker.datePickerMode = .date
        viewedDatePicker.preferredDatePickerStyle = .compact
        viewedDatePicker.calendar = Calendar(identifier: .gregorian)
        viewedDatePicker.locale = Locale(identifier: "ko_KR")
        
        ratingView.setRating(3.5)
        
        var saveButtonConfig = UIButton.Configuration.plain()
        saveButtonConfig.title = "새 기록 만들기"
        saveButtonConfig.background.image = .bubble24Blue
        saveButtonConfig.baseBackgroundColor = .clear
        saveButtonConfig.baseForegroundColor = .white
        saveButtonConfig.titleTextAttributesTransformer = .init({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        })
        saveButton.configuration = saveButtonConfig
        saveButton.layer.cornerRadius = 24
        // saveButton은 약간
        let saveButtonWhiteningView = UIView()
        saveButtonWhiteningView.backgroundColor = .white
        saveButtonWhiteningView.alpha = 0.1
        saveButtonWhiteningView.isUserInteractionEnabled = false
        saveButtonWhiteningView.layer.cornerRadius = 24
        saveButton.insertSubview(saveButtonWhiteningView, at: 0)
        saveButtonWhiteningView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        var dismissButtonConfig = UIButton.Configuration.plain()
        dismissButtonConfig.title = "취소"
        dismissButtonConfig.background.image = .bubble24Blue
        dismissButtonConfig.baseBackgroundColor = .clear
        dismissButtonConfig.baseForegroundColor = .white
        dismissButtonConfig.titleTextAttributesTransformer = .init({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            return outgoing
        })
        dismissButton.configuration = dismissButtonConfig
        dismissButton.layer.cornerRadius = 24
    }
    
    func setupHierarchy() {
        addSubview(ticketView)
        ticketView.insertSubview(ticketBlurBackground, at: 0)
        ticketView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        addSubview(saveButton)
        addSubview(dismissButton)
    }
    
    func setupLayoutConstraints() {
        ticketView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(6)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        ticketBlurBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(ticketView.cornerRadius)
            make.leading.trailing.equalToSuperview().inset(ticketView.cornerRadius)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(ticketView.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(48)
        }
        
        dismissButton.snp.contentHuggingHorizontalPriority = 800
        dismissButton.snp.makeConstraints { make in
            make.centerY.height.equalTo(saveButton)
            make.leading.equalTo(saveButton.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(24)
        }
        
        contentStackView.snp.makeConstraints { $0.edges.width.equalToSuperview() }
    }
    
    
    // MARK: - Layout
    private func setupContentStack(with performance: Performance) {
        
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
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, content])
        stackView.axis = axis
        stackView.spacing = spacing
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.verticalEdges.equalToSuperview().inset(20)
        }
        
        return containerView
    }
    private func createPerformanceHeader(with performance: Performance) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.text = performance.name
        
        let venueLabel = UILabel()
        venueLabel.font = .systemFont(ofSize: 14)
        venueLabel.textColor = .secondaryLabel
        venueLabel.text = performance.facilityFullName
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, venueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        containerView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.verticalEdges.equalToSuperview().inset(20)
        }
        return containerView
    }
    
    private func createMemoView() -> UIView {
        memoTextView.backgroundColor = .white.withAlphaComponent(0.3)
        memoTextView.layer.cornerRadius = 10
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        memoTextView.typingAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 15)
        ]
        memoTextView.snp.makeConstraints { make in
            make.height.equalTo(130)
        }
        return memoTextView
    }
    private func createPhotoSection() -> UIView {
        configureImageAddBox()
        let container = UIView()
        container.addSubview(imageAddBox)
        container.addSubview(imagesCollectionView)
        container.addSubview(imageLoadingIndicator)
        
        imageLoadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
        imageAddBox.snp.makeConstraints { $0.edges.equalToSuperview() }
        imagesCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        imagesCollectionView.isHidden = true
        
        return container
    }
    private func configureImageAddBox() {
        imageAddBox.backgroundColor = .white.withAlphaComponent(0.3)
        imageAddBox.layer.cornerRadius = 10
        imageAddBox.layer.borderWidth = 1
        imageAddBox.layer.borderColor = UIColor.systemGray3.cgColor
        
        imageAddBox.addGestureRecognizer(imageBoxTapGesture)
        
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
    
}


extension AddRecordView {
    
    func updatePhotoSection(imageCount: Int) {
        let hasImages = imageCount > 0
        imagesCollectionView.isHidden = !hasImages
        imageAddBox.isHidden = hasImages
        imageLoadingIndicator.isHidden = !hasImages
        imageLoadingIndicator.stopAnimating()
        imagesCollectionView.reloadData()
        
        // 이미지 추가 박스의 레이블 업데이트
        if let label = imageAddBox.subviews
            .compactMap({ $0 as? UIStackView })
            .first?.arrangedSubviews
            .compactMap({ $0 as? UILabel }).first {
            label.text = "이미지 추가 (\(imageCount)/5)"
        }
    }
    
}
