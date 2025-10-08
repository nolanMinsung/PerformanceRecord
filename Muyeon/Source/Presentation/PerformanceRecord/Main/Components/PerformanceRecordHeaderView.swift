//
//  PerformanceRecordHeaderView.swift
//  Muyeon
//
//  Created by 김민성 on 10/8/25.
//

import UIKit

import RxSwift
import SnapKit

// MARK: - 공연 기록 컬렉션 뷰 헤더
final class PerformanceRecordHeaderView: UICollectionReusableView {
    
    private(set) var disposeBag = DisposeBag()
    
    // -- UI Components --
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "관람 기록"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "공연예술 관람 기록을 관리하세요"
        label.textColor = .secondaryLabel
        return label
    }()
    
    let statsSummaryView = StatsSummaryView()
    let recentViewCard = InfoCardView(iconName: "clock.arrow.circlepath", title: "최근 관람")
    let mostViewedCard = InfoCardView(iconName: "trophy.fill", title: "최다 관람")
    
    private let recordsListHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "내 공연 기록"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    let addRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("즐겨찾기한 공연", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    private lazy var recordsListHeaderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [recordsListHeaderLabel, addRecordButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 4
        titleStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [
            titleStack,
            statsSummaryView,
            recentViewCard,
            mostViewedCard,
            recordsListHeaderStack
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(20, after: mostViewedCard)
        return stack
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        addRecordButton.snp.makeConstraints { make in
//            make.width.equalTo(90)
            make.height.equalTo(36)
        }
    }
}


// MARK: - Configuring View Contents
extension PerformanceRecordHeaderView {
    
    func configureStats(
        totalCount: Int,
        performanceCount: Int,
        averageRating: Double,
        thisYearCount: Int,
        photoCount: Int
    ) {
        statsSummaryView.configure(
            totalCount: totalCount,
            performanceCount: performanceCount,
            averageRating: averageRating,
            thisYearCount: thisYearCount,
            photoCount: photoCount,
        )
    }
    
    func configureRecentRecord(recentRecord: Record?, performance: Performance) {
        if let recentRecord {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM월 dd일"
            recentViewCard.isHidden = false
            recentViewCard.configure(
                mainText: performance.name,
                tagText: "★ \(recentRecord.rating)",
                tagColor: .systemOrange,
                subText: dateFormatter.string(from: recentRecord.viewedAt)
            )
        } else {
            recentViewCard.isHidden = true
        }
    }
    
    func configureMostViewed(mostViewedPerformance: Performance) {
        let recordCount = mostViewedPerformance.records.count
        if recordCount > 0 {
            mostViewedCard.isHidden = false
            mostViewedCard.configure(
                mainText: mostViewedPerformance.name,
                tagText: "\(recordCount)회",
                tagColor: .systemIndigo,
                subText: mostViewedPerformance.facilityFullName
            )
        } else {
            mostViewedCard.isHidden = true
        }
    }
}
