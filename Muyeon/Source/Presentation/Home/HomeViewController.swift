//
//  HomeViewController.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<HomeView.Section, String>
    typealias CellProvider = DiffableDataSource.CellProvider
    typealias SupplementaryViewProvider = DiffableDataSource.SupplementaryViewProvider
    typealias TopTenCellRegistration = UICollectionView.CellRegistration<HomeTopTenCell, String>
    typealias TopTenHeaderRegistration = UICollectionView.SupplementaryRegistration<HomeTopTenHeaderView>
    typealias TrendingCellRegistration = UICollectionView.CellRegistration<HomeTrendingCell, String>
    typealias TrendingHeaderRegistration = UICollectionView.SupplementaryRegistration<HomeTrendingHeaderView>
    
    private var topTenContents: [String] = ["0-0", "0-1", "0-2", "0-3", "0-4", "0-5", "0-6", "0-7", "0-8", "0-9"]
    private var trendingContents: [String] = [
        "1-0", "1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8", "1-9",
        "1-10", "1-11", "1-12", "1-13", "1-14", "1-15", "1-16", "1-17", "1-18", "1-19"
    ]
    
    private var dataSource: DiffableDataSource!
    
    private let rootView = HomeView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        applySnapshot()
    }
    
}


private extension HomeViewController {
    
    func setupCollectionView() {
        
        let topTenCellRegistration = TopTenCellRegistration { cell, indexPath, itemIdentifier in
            // configuring Cell...
        }
        
        let trendingCellRegistration = TrendingCellRegistration { cell, indexPath, itemIdentifier in
            // configuring Cell...
        }
        
        let cellProvider: CellProvider = { collectionView, indexPath, itemIdentifier in
            switch indexPath.section {
            case 0:
                return collectionView.dequeueConfiguredReusableCell(
                    using: topTenCellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            default:
                return collectionView.dequeueConfiguredReusableCell(
                    using: trendingCellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            }
        }
        
        dataSource = DiffableDataSource(
            collectionView: rootView.homeCollectionView,
            cellProvider: cellProvider
        )
        
        let topTenHeaderRegistration = TopTenHeaderRegistration(
            elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
                // configuring supplementaryView...
            }
        
        let trendingHeaderRegistration = TrendingHeaderRegistration(
            elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
                // configurint supplementaryView
            }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch indexPath.section {
            case 0:
                return collectionView.dequeueConfiguredReusableSupplementary(using: topTenHeaderRegistration, for: indexPath)
            default:
                return collectionView.dequeueConfiguredReusableSupplementary(using: trendingHeaderRegistration, for: indexPath)
            }
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeView.Section, String>()
        snapshot.appendSections(HomeView.Section.allCases)
        snapshot.appendItems(topTenContents, toSection: .topTen)
        snapshot.appendItems(trendingContents, toSection: .trending)
        dataSource.apply(snapshot)
    }
    
}
