//
//  SubVenueInfoView.swift
//  Muyeon
//
//  Created by 김민성 on 9/30/25.
//

import UIKit

// MARK: - SubVenueInfoView (메인 뷰)
/// SubVenue 정보를 받아 화면을 구성하는 메인 뷰
class SubVenueInfoView: UIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let seatScaleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        // 내부 컨텐츠에 맞게 패딩을 추가하기 위해 content hugging/compression resistance 우선순위 조절
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    // 좌석수 레이블의 좌우 패딩을 위한 컨테이너 뷰
    private lazy var seatScaleContainer: UIView = {
        let view = UIView()
        view.addSubview(seatScaleLabel)
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        seatScaleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        return view
    }()

    private let stageFacilitiesLabel: UILabel = {
        let label = UILabel()
        label.text = "무대시설"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    private let disabledFacilitiesLabel: UILabel = {
        let label = UILabel()
        label.text = "장애인시설"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    private let otherFacilitiesLabel: UILabel = {
        let label = UILabel()
        label.text = "기타"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .gray
        return label
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 8
        return stackView
    }()
    
    private let stageFacilitiesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let disabledFacilitiesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let otherFacilitiesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        // 뷰 계층 구조 설정
        headerStackView.addArrangedSubview(nameLabel)
        headerStackView.addArrangedSubview(seatScaleContainer)
        
        mainStackView.addArrangedSubview(headerStackView)
        mainStackView.addArrangedSubview(stageFacilitiesLabel)
        mainStackView.addArrangedSubview(stageFacilitiesStackView)
        mainStackView.addArrangedSubview(disabledFacilitiesLabel)
        mainStackView.addArrangedSubview(disabledFacilitiesStackView)
        mainStackView.addArrangedSubview(otherFacilitiesLabel)
        mainStackView.addArrangedSubview(otherFacilitiesStackView)
        
        // 메인 스택뷰의 각 섹션 사이 간격 조절
        mainStackView.setCustomSpacing(12, after: stageFacilitiesLabel)
        mainStackView.setCustomSpacing(12, after: disabledFacilitiesLabel)
        mainStackView.setCustomSpacing(12, after: otherFacilitiesLabel)
        
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }
    }

    // MARK: - Configuration
    
    public func configure(with venue: SubVenue) {
        // 기본 정보 설정
        nameLabel.text = venue.name
        seatScaleLabel.text = "\(venue.seatScale) 석"
        
        // 재사용을 위해 기존 태그들을 모두 제거
        stageFacilitiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        disabledFacilitiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        otherFacilitiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 무대시설 태그 구성
        var stageTags: [UIView] = []
        
        if venue.hasOrchestraPit {
            let tag = SubVenueInfoTagView(icon: UIImage(systemName: "music.note"), text: "오케스트라피트", color: .systemGreen)
            stageTags.append(tag)
        }
        if venue.hasPracticeRoom {
            let tag = SubVenueInfoTagView(icon: UIImage(systemName: "person.2.fill"), text: "연습실", color: .systemGreen)
            stageTags.append(tag)
        }
        if venue.hasDressingRoom {
            let tag = SubVenueInfoTagView(icon: UIImage(systemName: "paintpalette.fill"), text: "분장실", color: .systemGreen)
            stageTags.append(tag)
        }
        if venue.hasOutdoorStage {
            let tag = SubVenueInfoTagView(icon: UIImage(systemName: "bell.fill"), text: "야외공연장", color: .systemGreen)
            stageTags.append(tag)
        }
        
        // 무대시설 태그를 2열 그리드로 배치
        for i in stride(from: 0, to: stageTags.count, by: 2) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 10
            rowStackView.distribution = .fillEqually
            
            // 짝수 번째의(0번 포함) 태그 추가
            rowStackView.addArrangedSubview(stageTags[i])
            
            // 홀수 번째의 태그 추가
            if i + 1 < stageTags.count {
                rowStackView.addArrangedSubview(stageTags[i+1])
            } else {
                // 홀수 번째의 태그가 올 자리인데, 더 추가할 태그가 없는 상황(모든 태그를 순회함) -> 태그가 홀수 개인 경우.
                // 태그가 홀수 개일 경우, 레이아웃 유지를 위해 빈 뷰 추가
                rowStackView.addArrangedSubview(UIView())
            }
            stageFacilitiesStackView.addArrangedSubview(rowStackView)
        }
        
        // 무대시설 섹션 전체의 표시 여부 결정
        let hasStageFacilities = !stageTags.isEmpty
        stageFacilitiesLabel.isHidden = !hasStageFacilities
        stageFacilitiesStackView.isHidden = !hasStageFacilities

        // 장애인시설 태그 구성
        var disabledTags: [UIView] = []
        if let disabledSeats = venue.disabledSeatScale, disabledSeats > 0 {
            let text = "장애인 전용 관람석: \(disabledSeats)석"
            let tag = SubVenueInfoTagView(icon: UIImage(systemName: "figure.roll"), text: text, color: .systemBlue)
            disabledTags.append(tag)
        }
        
        disabledTags.forEach(disabledFacilitiesStackView.addArrangedSubview)
        
        // 장애인시설 섹션 전체의 표시 여부 결정
        let hasDisabledFacilities = !disabledTags.isEmpty
        disabledFacilitiesLabel.isHidden = !hasDisabledFacilities
        disabledFacilitiesStackView.isHidden = !hasDisabledFacilities
        
        // 기타 섹션 태그 구성
        var otherTags: [UIView] = []
        if let stageArea = venue.stageArea {
            let tag = SubVenueInfoTagView(icon: UIImage(systemName: "ruler.fill"), text: "무대넓이: \(stageArea)", color: .systemBlue)
            otherTags.append(tag)
        }
        
        otherTags.forEach(otherFacilitiesStackView.addArrangedSubview)
        
        // 기타 섹션 전체의 표시 여부 결정
        let hasOtherFacilities = !otherTags.isEmpty
        otherFacilitiesLabel.isHidden = !hasOtherFacilities
        otherFacilitiesStackView.isHidden = !hasOtherFacilities
    }
    
}
