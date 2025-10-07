//
//  PerformanceRecordView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import SnapKit

// MARK: - 공연 기록 메인 뷰
class PerformanceRecordView: UIView {
    
    private let scrollView = UIScrollView()
    
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
        button.setTitle("새 기록 추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var recordsListHeaderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [recordsListHeaderLabel, addRecordButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.contentInset = .zero
        collectionView.register(PerformanceRecordCell.self, forCellWithReuseIdentifier: PerformanceRecordCell.reuseIdentifier)
        return collectionView
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
            recordsListHeaderStack,
            collectionView
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.setCustomSpacing(40, after: statsSummaryView)
        return stack
    }()
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        scrollView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).inset(16)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide).inset(20)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(20)
        }
        
        addRecordButton.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(36)
        }
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 50)
        collectionViewHeightConstraint?.isActive = true
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(180))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(180))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateCollectionViewHeight() {
        collectionView.layoutIfNeeded()
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        if height > 0 {
             collectionViewHeightConstraint?.constant = height
        }
    }
    
}
