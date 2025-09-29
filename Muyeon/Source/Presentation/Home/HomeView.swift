//
//  HomeView.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

import SnapKit

final class HomeView: UIView {
    
    enum Section: Hashable, CaseIterable {
        case topTen // 오늘 TOP 10
        case trending // 지금 뜨는 공연
    }
    
    private let top10TitleLabel = UILabel()
    private let trendingPerformanceTitleLabel = UILabel()
    private(set) var homeCollectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - Initial Settings
extension HomeView: BaseViewSettings {
    
    func setupUIProperties() {
        top10TitleLabel.text = "오늘 TOP 10"
        top10TitleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        
        homeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        
        trendingPerformanceTitleLabel.text = "지금 뜨는 공연"
        trendingPerformanceTitleLabel.font = .systemFont(ofSize: 25, weight: .bold)
    }
    
    func setupHierarchy() {
        addSubview(homeCollectionView)
    }
    
    func setupLayoutConstraints() {
        homeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}


private extension HomeView {
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let sections: [Section] = [.topTen, .trending]
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let section = sections[sectionIndex]
            switch section {
            case .topTen:
                return self.createTopTenSection()
            case .trending:
                return self.createTrendingSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10.0
        layout.configuration = config
        
        return layout
    }
    
    func createTopTenSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let groupWidthRatio: CGFloat = 0.7
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupWidthRatio),
            heightDimension: .fractionalWidth(groupWidthRatio * 1.3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        section.visibleItemsInvalidationHandler = {
            visibleItems,
            scrollOffset,
            layoutEnvironment in
            // 컬렉션뷰의 centerX 좌표 계산
            let collectionViewCenterX = scrollOffset.x + layoutEnvironment.container.contentSize.width / 2
            
            let scalingFactor: CGFloat = 0.0007
            let maxScale: CGFloat = 1.0
            let minScale: CGFloat = 0.8
            
            for item in visibleItems {
                // 헤더는 제외
                guard (item.representedElementCategory == .cell) else { continue }
                // 아이템의 centerX 좌표
                let itemCenterX = item.center.x
                
                // 중앙으로부터의 거리
                let distance = itemCenterX - collectionViewCenterX
                
                // 거리에 비례하여 scale 계산 및 적용
                let normalizedDistance = abs(distance) * scalingFactor
                let scale = max(minScale, maxScale - normalizedDistance)
                let xPositionDiff = -distance * 0.1
                
                let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
                let positionTransform = CGAffineTransform(translationX: xPositionDiff, y: 0)
                item.transform = positionTransform.concatenating(scaleTransform)
                item.zIndex = Int(scale * 10)
            }
        }
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
        sectionHeader.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }

    func createTrendingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.6)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 3
        )
        
        let spacing: CGFloat = 10
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        section.interGroupSpacing = spacing
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
}
