//
//  RecordDetailView.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit

import SnapKit

class RecordDetailView: UIView {
    
    // MARK: - UI Components
    private let performanceInfoView = PerformanceHeaderView()
    
    let addRecordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "공연 기록 남기기"
        config.baseBackgroundColor = .Main.primary.withAlphaComponent(0.1)
        config.baseForegroundColor = .Main.primary
        config.cornerStyle = .large
        config.titleTextAttributesTransformer = .init({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        })
        let button = ShrinkableButton(configuration: config)
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(performanceInfoView)
        addSubview(addRecordButton)
        addSubview(collectionView)
    }
    
    private func setupLayout() {
        performanceInfoView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(30)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        addRecordButton.snp.makeConstraints { make in
            make.top.equalTo(performanceInfoView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(performanceInfoView)
            make.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(addRecordButton.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    func configureHeader(with performance: Performance, poster: UIImage?) {
        performanceInfoView.configure(with: performance, poster: poster)
    }
    
    // MARK: - Compositional Layout
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)

        // 섹션 헤더 설정
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

