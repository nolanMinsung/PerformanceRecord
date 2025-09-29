//
//  PerformanceDetailView.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

import UIKit
import SnapKit

final class PerformanceDetailView: UIView {

    // MARK: - UI Components
    
    // --- 최상단 뷰 ---
    private let scrollView = UIScrollView()

    // --- 포스터 및 정보 섹션 ---
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        // 실제 앱에서는 URL로부터 이미지를 비동기적으로 로드해야 합니다.
        // 여기서는 임시로 시스템 이미지를 사용합니다.
        imageView.image = UIImage(systemName: "photo.artframe")
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray // 이미지 로딩 전 배경색
        return imageView
    }()
    
    private let gradientView = BottomGradientView(color: .systemBackground)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "2025 최현우 아판타시아 - 서울: 이 문자열이 길다면? 세 줄까지도 가능해질까?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(configuration: .plain())
        var unselectedConfig = UIButton.Configuration.plain()
        unselectedConfig.image = UIImage(systemName: "heart")
        unselectedConfig.baseForegroundColor = .systemRed
        unselectedConfig.contentInsets = .zero
        
        var selectedConfig = UIButton.Configuration.plain()
        selectedConfig.image = UIImage(systemName: "heart.fill")
        selectedConfig.baseForegroundColor = .systemRed
        selectedConfig.contentInsets = .zero
        
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
        label.text = "뮤지컬"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "2시간"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let ageRatingLabel: UILabel = {
        let label = UILabel()
        label.text = "만 13세 이상"
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
    
    private let venueButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .init(systemName: "chevron.forward")
        config.baseForegroundColor = .label
        config.title = "한전아트센터"
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = .zero
        config.titleTextAttributesTransformer = .init { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16)
            return outgoing
        }
        let button = UIButton(configuration: config)
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
        label.text = "2025.10.25 - 2025.11.09"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
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
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis vehicula risus eleifend laoreet et scelerisque leo. Fusce et quam quis turpis semper sagittis nec eu neque. Nullam imperdiet, mi facilisis lacinia pretium, lectus sapien efficitur massa, ut pretium ipsum lorem sed magna. Vivamus tincidunt aliquam. Pellentesque et hendrerit."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let additionalImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let additionalImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "photo.artframe")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray // 이미지 로딩 전 배경색
        return imageView
    }()
    
    private let additionalImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "photo.artframe")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray // 이미지 로딩 전 배경색
        return imageView
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
        // 가변적인 데이터에 대응하기 위해 dot label을 별도로 추가합니다.
        let dotLabel1 = createDotLabel()
        let dotLabel2 = createDotLabel()
        [genreLabel, dotLabel1, durationLabel, dotLabel2, ageRatingLabel].forEach {
            detailsStackView.addArrangedSubview($0)
        }
        
        // 장소/기간 컨테이너 뷰
        venueContainerView.addSubview(venueTitleLabel)
        venueContainerView.addSubview(venueButton)
        
        periodContainerView.addSubview(periodTitleLabel)
        periodContainerView.addSubview(periodLabel)
        
        // 추가 줄거리 이미지
        additionalImageStackView.addArrangedSubview(additionalImageView1)
        additionalImageStackView.addArrangedSubview(additionalImageView2)
    }

    /// 오토레이아웃 제약조건을 설정합니다.
    private func setupLayoutConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 포스터 이미지
        posterImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).inset(-2) // UIKit 버그인 듯. 1~2포인트 정도 여백이 생김.
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(posterImageView.snp.width).multipliedBy(1.2) // 이미지 비율을 대략 1:1.2로 설정
        }
        
        // 그라데이션 뷰
        gradientView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(posterImageView)
            make.height.equalTo(200)
        }
        
        // 타이틀
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
        venueButton.snp.makeConstraints { make in
            make.leading.equalTo(venueTitleLabel.snp.trailing).offset(8)
            make.verticalEdges.trailing.equalToSuperview()
        }
        
        // 기간 뷰
        periodTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(35) // "장소", "기간" 너비 고정
        }
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
        
        additionalImageView1.snp.makeConstraints { make in
            guard let image = additionalImageView1.image else { return }
            let aspectRatio = image.size.height / image.size.width
            make.height.equalTo(additionalImageView1.snp.width).multipliedBy(aspectRatio)
        }
        additionalImageView2.snp.makeConstraints { make in
            guard let image = additionalImageView2.image else { return }
            let aspectRatio = image.size.height / image.size.width
            make.height.equalTo(additionalImageView2.snp.width).multipliedBy(aspectRatio)
        }
        
        additionalImageStackView.snp.makeConstraints { make in
            make.top.equalTo(storyBodyLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide)
        }
    }
    
    // MARK: - Helper Methods
    
    /// 상세 정보 스택뷰에 사용될 구분자(dot) 라벨을 생성합니다.
    private func createDotLabel() -> UILabel {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        return label
    }
}
