//
//  StatsSummaryView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

// MARK: - 통계 요약 뷰
class StatsSummaryView: UIView {

    // MARK: - Properties
    private let totalCountView = StatItemView(iconName: "calendar", title: "총 관람 횟수")
    private let averageRatingView = StatItemView(iconName: "star.fill", title: "평균 평점")
    private let thisYearCountView = StatItemView(iconName: "chart.line.uptrend.xyaxis", title: "올해 관람")
    private let totalPhotosView = StatItemView(iconName: "photo", title: "총 사진")

    private lazy var stackView: UIStackView = {
        let hStack1 = UIStackView(arrangedSubviews: [totalCountView, averageRatingView])
        hStack1.axis = .horizontal
        hStack1.distribution = .fillEqually
        hStack1.spacing = 16

        let hStack2 = UIStackView(arrangedSubviews: [thisYearCountView, totalPhotosView])
        hStack2.axis = .horizontal
        hStack2.distribution = .fillEqually
        hStack2.spacing = 16

        let vStack = UIStackView(arrangedSubviews: [hStack1, hStack2])
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 16
        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configure(totalCount: Int, performanceCount: Int, averageRating: Double, thisYearCount: Int, photoCount: Int) {
        totalCountView.updateValue(mainText: "\(totalCount)", subText: "\(performanceCount)개 공연")
        averageRatingView.updateValue(mainText: String(format: "%.1f", averageRating), subText: "5점 만점")
        thisYearCountView.updateValue(mainText: "\(thisYearCount)", subText: "\(Calendar.current.component(.year, from: Date()))년")
        totalPhotosView.updateValue(mainText: "\(photoCount)", subText: "업로드된 사진")
    }

    // MARK: - Private Methods
    private func setupUI() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
