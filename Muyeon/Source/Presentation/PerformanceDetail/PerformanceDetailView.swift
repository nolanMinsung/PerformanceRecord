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
    private let scrollView = UIScrollView()

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
        let button = UIButton(configuration: config)
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
//        label.text = "2025.10.25 - 2025.11.09"
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
        scrollView.contentInsetAdjustmentBehavior = .never
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
        scrollView.addSubview(additionalImageStackView)
        
        // 세로 정보 스택 뷰
        infoStackView.addArrangedSubview(detailsStackView)
        infoStackView.addArrangedSubview(venueContainerView)
        infoStackView.addArrangedSubview(periodContainerView)
        
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
        
        // 기간 뷰
        periodTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(35) // "장소", "기간" 너비 고정
        }
        
        // 상연 기간
        periodLabel.snp.makeConstraints { make in
            make.leading.equalTo(periodTitleLabel.snp.trailing).offset(8)
            make.verticalEdges.trailing.equalToSuperview()
        }
        
        // 줄거리 제목
        storyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
        
        // 줄거리 내용
        storyBodyLabel.snp.makeConstraints { make in
            make.top.equalTo(storyTitleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(storyTitleLabel)
        }
        
        additionalImageStackView.snp.makeConstraints { make in
            make.top.equalTo(storyBodyLabel.snp.bottom).offset(30)
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
        likeButton.isSelected = likePerformanceIDs.contains(performance.id)
        genreLabel.text = performance.genre.description
        durationLabel.text = performance.detail?.runtime ?? "-시간"
        ageRatingLabel.text = performance.detail?.ageLimit
        storyBodyLabel.text = performance.detail?.story
        if #available(iOS 16.0, *) {
            let (placeName, placeDetail) = performance.facilityFullName.parsePlaceAndDetail()!
            facilityButton.configuration?.title = placeName
            facilityButton.configuration?.subtitle = placeDetail
        } else {
            facilityButton.configuration?.title = performance.facilityFullName
        }
        periodLabel.text = performance.detail?.detailDateGuidance.replacingOccurrences(of: ", ", with: "\n")
        
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
