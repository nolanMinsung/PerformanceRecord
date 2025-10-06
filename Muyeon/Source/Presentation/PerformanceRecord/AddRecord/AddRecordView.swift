//
//  AddRecordView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class AddRecordView: UIView {
    
    // MARK: - UI Components (ViewController에서 접근 필요)
    let memoTextView = UITextView()
    let imagesCollectionView: UICollectionView
    
    // MARK: - Actions (Closures)
    var onDateChanged: ((Date) -> Void)?
    var onRatingChanged: ((Int) -> Void)?
    var onAddImageTapped: (() -> Void)?
    var onSaveButtonTapped: (() -> Void)?
    var onDeleteImage: ((Int) -> Void)?
    
    // MARK: - Private UI Components
    private let dateTextField = UITextField()
    private let imageAddBox = UIView()
    private var ratingButtons: [UIButton] = []
    private let ratingValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.text = "5점"
        return label
    }()
    
    init(performance: Performance) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        self.imagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        imagesCollectionView.register(AddedPhotoCell.self, forCellWithReuseIdentifier: AddedPhotoCell.identifier)
        setupLayout(with: performance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func updatePhotoSection(imageCount: Int) {
        let hasImages = imageCount > 0
        imagesCollectionView.isHidden = !hasImages
        imageAddBox.isHidden = hasImages
        imagesCollectionView.reloadData()
        
        // 이미지 추가 박스의 레이블 업데이트
        if let label = imageAddBox.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.compactMap({ $0 as? UILabel }).first {
            label.text = "이미지 추가 (\(imageCount)/5)"
        }
    }
    
    // MARK: - Layout
    private func setupLayout(with performance: Performance) {
        let scrollView = UIScrollView()
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        
        let bottomButtonStack = createBottomButtons()
        
        addSubview(scrollView)
        addSubview(bottomButtonStack)
        scrollView.addSubview(contentStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(400)
        }
        
        bottomButtonStack.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        contentStackView.snp.makeConstraints { $0.edges.width.equalToSuperview() }
        
        // 섹션 추가
        contentStackView.addArrangedSubview(createPerformanceHeader(with: performance))
        contentStackView.addArrangedSubview(createSection(title: "관람 날짜", content: createDatePicker(with: performance), axis: .horizontal))
        contentStackView.addArrangedSubview(createSection(title: "평점", content: createRatingControl(), axis: .horizontal))
        contentStackView.addArrangedSubview(createSection(title: "메모 (선택사항)", content: createMemoView()))
        contentStackView.addArrangedSubview(createSection(title: "사진 (선택사항)", content: createPhotoSection()))
    }
    
    // MARK: - UI Creation Methods
    private func createSection(title: String, content: UIView, axis: NSLayoutConstraint.Axis = .vertical) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, content])
        stackView.axis = axis
        stackView.spacing = 10
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
    private func createDatePicker(with performance: Performance) -> UIView {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.minimumDate = performance.startDate
        picker.maximumDate = performance.endDate
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko_KR")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
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
    private func createBottomButtons() -> UIView {
        let backButton = UIButton()
        backButton.setTitle("뒤로", for: .normal)
        backButton.backgroundColor = .systemGray5
        backButton.setTitleColor(.label, for: .normal)
        backButton.layer.cornerRadius = 10
        
        let saveButton = UIButton()
        saveButton.setTitle("기록 저장", for: .normal)
        saveButton.backgroundColor = .label
        saveButton.setTitleColor(.systemBackground, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [backButton, saveButton])
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }
    private func createRatingControl() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 10

        // 별점 버튼들을 담을 스택뷰
        let starButtonStack = UIStackView()
        starButtonStack.axis = .horizontal
        starButtonStack.spacing = 2
        
        // 이전에 생성된 버튼이 있다면 제거
        ratingButtons.removeAll()

        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button.tintColor = .systemYellow
            button.tag = i // 각 버튼을 식별하기 위해 태그 설정
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            
            ratingButtons.append(button)
            starButtonStack.addArrangedSubview(button)
            
            button.snp.makeConstraints { make in
                make.width.height.equalTo(28) // 버튼 크기 고정
            }
        }
        
        // 별점 버튼, 점수 라벨, 드롭다운 아이콘을 모두 담는 최종 스택뷰
        let mainStack = UIStackView(arrangedSubviews: [starButtonStack, ratingValueLabel])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.alignment = .center

        container.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(8)
        }

        // 점수 라벨이 다른 요소에 의해 눌리지 않도록 우선순위 설정
        ratingValueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        return container
    }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy. MM. dd."
        dateTextField.text = formatter.string(from: sender.date)
        onDateChanged?(sender.date)
    }
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        let selectedRating = sender.tag
        for button in ratingButtons {
            button.setImage(UIImage(systemName: button.tag <= selectedRating ? "star.fill" : "star"), for: .normal)
        }
        ratingValueLabel.text = "\(selectedRating)점"
        onRatingChanged?(selectedRating)
    }
    @objc private func addImageTapped() { onAddImageTapped?() }
    @objc private func saveButtonTapped() { onSaveButtonTapped?() }
}
