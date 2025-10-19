//
//  PerformanceDetailView.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

import Kingfisher
import SnapKit

final class PerformanceDetailView: UIView {

    // MARK: - UI Components
    
    // --- 최상단 뷰 ---
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    // --- 포스터 및 정보 섹션 ---
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let gradientView = BottomGradientView(color: .systemBackground)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(configuration: .plain())
        var unselectedConfig = UIButton.Configuration.plain()
        unselectedConfig.baseForegroundColor = .systemRed
        unselectedConfig.baseBackgroundColor = .clear
        unselectedConfig.contentInsets = .zero
        unselectedConfig.image = UIImage(systemName: "heart")?.resized(ratio: 1.5).withRenderingMode(.alwaysTemplate)
        
        var selectedConfig = unselectedConfig
        selectedConfig.image = UIImage(systemName: "heart.fill")?.resized(ratio: 1.5).withRenderingMode(.alwaysTemplate)
        
        button.configurationUpdateHandler = { button in
            button.configuration = button.isSelected ? selectedConfig : unselectedConfig
        }
        button.isEnabled = false
        return button
    }()
    
    // --- 상세 정보 스택 뷰 ---
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    // --- 장르/시간/연령 정보 (가로 스택) ---
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.alignment = .center
        return stackView
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let ageRatingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    // --- 장소 정보 ---
    private let venueContainerView = UIView()
    private let venueTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "장소"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    let facilityButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .init(systemName: "chevron.forward")
        config.baseForegroundColor = .label
        config.title = ""
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = .zero
        config.titleAlignment = .leading
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        let button = ShrinkableButton(configuration: config)
        button.isEnabled = false
        return button
    }()
    
    // --- 기간 정보 ---
    private let periodContainerView = UIView()
    private let periodTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "기간"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    // --- 시간 정보 ---
    private let timeGuidanceContainerView = UIView()
    private let timeGuidanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "시간"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    private let timeGuidanceLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    // --- 줄거리 섹션 ---
    private let storyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "줄거리"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let storyBodyLabel: UILabel = {
        let label = UILabel()
        label.text = "" /*"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis vehicula risus eleifend laoreet et scelerisque leo. Fusce et quam quis turpis semper sagittis nec eu neque. Nullam imperdiet, mi facilisis lacinia pretium, lectus sapien efficitur massa, ut pretium ipsum lorem sed magna. Vivamus tincidunt aliquam. Pellentesque et hendrerit."*/
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    let addRecordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "이 공연을 관람했나요?"
        config.subtitle = "공연 기록을 추가해보세요"
        config.titlePadding = 5
        config.titleAlignment = .center
        config.baseBackgroundColor = .Main.primary.withAlphaComponent(0.1)
        config.baseForegroundColor = .Main.primary
        config.cornerStyle = .large
        config.titleTextAttributesTransformer = .init({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        })
        
        var disableConfig = config
        disableConfig.title = "지금은 공연 기록을 추가할 수 없어요."
        disableConfig.subtitle = "공연이 시작하면 관람 후 기록해보세요."
        
        let button = ShrinkableButton(configuration: config)
        button.configurationUpdateHandler = { button in
            button.configuration = button.isEnabled ? config : disableConfig
        }
        button.isEnabled = false
        button.isHidden = true
        return button
    }()
    
    private let additionalImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIProperties() {
        likeButton.isHidden = true
        detailsStackView.isHidden = true
        venueContainerView.isHidden = true
        periodContainerView.isHidden = true
        timeGuidanceContainerView.isHidden = true
        storyTitleLabel.isHidden = true
        storyBodyLabel.isHidden = true
    }
    
    private func setupHierarchy() {
        addSubview(scrollView)
        
        scrollView.addSubview(posterImageView)
        scrollView.addSubview(gradientView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(likeButton)
        scrollView.addSubview(infoStackView)
        scrollView.addSubview(storyTitleLabel)
        scrollView.addSubview(storyBodyLabel)
        scrollView.addSubview(addRecordButton)
        scrollView.addSubview(additionalImageStackView)
        
        // 세로 정보 스택 뷰
        infoStackView.addArrangedSubview(detailsStackView)
        infoStackView.addArrangedSubview(venueContainerView)
        infoStackView.addArrangedSubview(periodContainerView)
        infoStackView.addArrangedSubview(timeGuidanceContainerView)
        infoStackView.addArrangedSubview(storyTitleLabel)
        infoStackView.addArrangedSubview(storyBodyLabel)
        
        // 가로 상세 정보 스택 뷰
        let dotLabel1 = createDotLabel()
        let dotLabel2 = createDotLabel()
        [genreLabel, dotLabel1, durationLabel, dotLabel2, ageRatingLabel].forEach {
            detailsStackView.addArrangedSubview($0)
        }
        
        // 장소/기간 컨테이너 뷰
        venueContainerView.addSubview(venueTitleLabel)
        venueContainerView.addSubview(facilityButton)
        
        periodContainerView.addSubview(periodTitleLabel)
        periodContainerView.addSubview(periodLabel)
        
        timeGuidanceContainerView.addSubview(timeGuidanceTitleLabel)
        timeGuidanceContainerView.addSubview(timeGuidanceLabel)
    }
    
    private func setupLayoutConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 포스터 이미지
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide)//.inset(-2) // UIKit 버그인 듯. 1~2포인트 정도 여백이 생김.
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(posterImageView.snp.width).multipliedBy(1.2) // 이미지 비율을 대략 1:1.2로 설정
        }
        
        // 그라데이션 뷰
        gradientView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(posterImageView)
            make.height.equalTo(200)
        }
        
        // 타이틀
        titleLabel.snp.contentHuggingHorizontalPriority = 249
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.frameLayoutGuide).inset(20)
            make.bottom.equalTo(posterImageView.snp.bottom)
        }
        
        // 좋아요 버튼
        likeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
            make.size.equalTo(55)
        }
        
        // 정보 스택뷰 (세로)
        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
        
        // 장소 뷰
        venueTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(35) // "장소", "기간" 너비 고정
        }
        
        // 장소 버튼
        facilityButton.snp.makeConstraints { make in
            make.leading.equalTo(venueTitleLabel.snp.trailing).offset(8)
            make.verticalEdges.trailing.equalToSuperview()
        }
        
        periodTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(35) // "장소", "기간", "시간" 너비 고정
        }
        
        periodLabel.snp.makeConstraints { make in
            make.leading.equalTo(periodTitleLabel.snp.trailing).offset(8)
            make.verticalEdges.trailing.equalToSuperview()
        }
        
        // 기간 뷰
        timeGuidanceTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(35) // "장소", "기간", "시간" 너비 고정
        }
        
        // 상연 기간
        timeGuidanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeGuidanceTitleLabel.snp.trailing).offset(8)
            make.verticalEdges.trailing.equalToSuperview()
        }
        
        addRecordButton.snp.makeConstraints { make in
            make.top.equalTo(storyBodyLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(infoStackView)
        }
        
        additionalImageStackView.snp.makeConstraints { make in
            make.top.equalTo(addRecordButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide)
        }
    }
    
    private func createDotLabel() -> UILabel {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }
}


extension PerformanceDetailView {
    
    @MainActor
    func update(with performance: Performance) {
        @UserDefault(key: .likePerformanceIDs, defaultValue: [])
        var likePerformanceIDs: [String]
        
        if posterImageView.image == nil {
            updatePosterImageView(with: performance.posterURL)
        }
        titleLabel.text = performance.name
        titleLabel.isHidden = false
        
        likeButton.isEnabled = true
        likeButton.isSelected = likePerformanceIDs.contains(performance.id)
        likeButton.isHidden = false
        
        genreLabel.text = performance.genre.description
        durationLabel.text = performance.detail?.runtime ?? "-시간"
        ageRatingLabel.text = performance.detail?.ageLimit
        detailsStackView.isHidden = false
        
        if #available(iOS 16.0, *) {
            let (placeName, placeDetail) = performance.facilityFullName.parsePlaceAndDetail()!
            facilityButton.configuration?.title = placeName
            facilityButton.configuration?.subtitle = placeDetail
        } else {
            facilityButton.configuration?.title = performance.facilityFullName
        }
        venueContainerView.isHidden = false
        
        let periodStartDate = performance.startDate.formatted(date: .abbreviated, time: .omitted)
        let periodEndDate = performance.endDate.formatted(date: .abbreviated, time: .omitted)
        periodLabel.text = "\(periodStartDate) ~ \(periodEndDate)"
        periodContainerView.isHidden = false
        
        timeGuidanceLabel.text = performance.detail?.detailDateGuidance.replacingOccurrences(of: ", ", with: "\n")
        timeGuidanceContainerView.isHidden = false
        
        if let story = performance.detail?.story, !story.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let attributedString = NSAttributedString(string: story, attributes: [.paragraphStyle: paragraphStyle])
            storyBodyLabel.attributedText = attributedString
            storyBodyLabel.isHidden = false
            storyTitleLabel.isHidden = false
        }
        
        let isPerformanceHasStart = Calendar(identifier: .gregorian)
            .compare(performance.startDate, to: .now, toGranularity: .day) != .orderedDescending
        if isPerformanceHasStart {
            let recordCount = performance.records.count
            let titleText = (recordCount == 0) ? "이 공연을 관람했나요?" : "이 공연을 \(recordCount)회 관람했어요."
            let subTitleText = (recordCount == 0) ? "공연 기록을 추가해보세요" : "n차 관람했다면 기록을 추가해보세요."
            addRecordButton.configuration?.title = titleText
            addRecordButton.configuration?.subtitle = subTitleText
        }
        addRecordButton.isHidden = false
        addRecordButton.isEnabled = isPerformanceHasStart
        
        updateAdditionalImages(urls: performance.detail?.detailImageURLs ?? [])
    }
    
    func updatePosterImageView(with urlString: String) {
        let posterURL = URL(string: urlString)
        posterImageView.kf.setImage(with: posterURL) { [weak self] _ in
            self?.updatePosterImageSize()
        }
    }
    
    func updatePosterImage(withThumbnail thumbnail: UIImage) {
        posterImageView.image = thumbnail
        updatePosterImageSize()
    }
    
    private func updatePosterImageSize() {
        guard let posterImageSize = posterImageView.image?.size else { return }
        let imageRatio = posterImageSize.height / posterImageSize.width
        
        posterImageView.snp.remakeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide)//.inset(-2) // UIKit 버그인 듯. 1~2포인트 정도 여백이 생김.
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(posterImageView.snp.width).multipliedBy(imageRatio) // 이미지 비율을 대략 1:1.2로 설정
        }
        setNeedsLayout()
    }
    
    private func updateAdditionalImages(urls: [String]) {
        let urls = urls.map { URL(string: $0) }
        for url in urls {
            Task {
                guard let url else { return }
                let imageResult = try await KingfisherManager.shared.retrieveImage(with: url)
                let imageView = UIImageView(image: imageResult.image)
                additionalImageStackView.addArrangedSubview(imageView)
                guard let image = imageView.image else { return }
                imageView.snp.makeConstraints { make in
                    let aspectRatio = image.size.height / image.size.width
                    make.height.equalTo(imageView.snp.width).multipliedBy(aspectRatio)
                }
            }
        }
    }
    
}
