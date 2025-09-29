//
//  HomeViewController.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<HomeView.Section, HomeUIModel>
    typealias CellProvider = DiffableDataSource.CellProvider
    typealias SupplementaryViewProvider = DiffableDataSource.SupplementaryViewProvider
    typealias TopTenCellRegistration = UICollectionView.CellRegistration<HomeTopTenCell, HomeUIModel>
    typealias TopTenHeaderRegistration = UICollectionView.SupplementaryRegistration<HomeTopTenHeaderView>
    typealias TrendingCellRegistration = UICollectionView.CellRegistration<HomeTrendingCell, HomeUIModel>
    typealias TrendingHeaderRegistration = UICollectionView.SupplementaryRegistration<HomeTrendingHeaderView>
    
    private let viewModel = HomeViewModel(
        fetchBoxOfficeUseCase: DefaultFetchBoxOfficeUseCase(),
        fetchPerformanceListUseCase: DefaultFetchPerformanceListUseCase()
    )
    
//    private var topTenContents: [String] = ["0-0", "0-1", "0-2", "0-3", "0-4", "0-5", "0-6", "0-7", "0-8", "0-9"]
//    private var trendingContents: [String] = [
//        "1-0", "1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8", "1-9",
//        "1-10", "1-11", "1-12", "1-13", "1-14", "1-15", "1-16", "1-17", "1-18", "1-19"
//    ]
    private var topTenContents: [HomeUIModel] = []
    private var trendingContents: [HomeUIModel] = []
    
    private var dataSource: DiffableDataSource!
    
    private let rootView = HomeView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        applySnapshot()
        
        // 박스오피스 정보 불러오기
        let boxOfficeRequestParam = BoxOfficeRequestParameter(
            service: InfoPlist.apiKey,
            stdate: .now.addingDay(-2),
            eddate: .now.addingDay(-2)
        )
        let performanceListParam = PerformanceListRequestParameter(
            stdate: .now.addingDay(-1),
            eddate: .now.addingDay(+29),
            cpage: 1,
            rows: 100
        )
        Task {
            do {
                let boxOfficeListResult = try await viewModel.fetchBoxOfficeUseCase.execute(
                    requestInfo: boxOfficeRequestParam
                )
                let performanceListResult = try await viewModel.fetchPerformanceListUseCase.execute(
                    requestInfo: performanceListParam
                )
//                dump(boxOfficeListResult)
                dump(performanceListResult)
                
                topTenContents = boxOfficeListResult.toDomain().map { .topTen(model: $0) }
                trendingContents = performanceListResult.toDomain().map { .trending(model: $0) }
                applySnapshot()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}


private extension HomeViewController {
    
    func setupCollectionView() {
        
        let topTenCellRegistration = TopTenCellRegistration { cell, indexPath, itemIdentifier in
            // configuring Cell...
            cell.configure(with: itemIdentifier)
        }
        
        let trendingCellRegistration = TrendingCellRegistration { cell, indexPath, itemIdentifier in
            // configuring Cell...
            cell.configure(with: itemIdentifier)
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
        var snapshot = NSDiffableDataSourceSnapshot<HomeView.Section, HomeUIModel>()
        snapshot.appendSections(HomeView.Section.allCases)
        snapshot.appendItems(Array(topTenContents.prefix(10)), toSection: .topTen)
        snapshot.appendItems(trendingContents, toSection: .trending)
        dataSource.apply(snapshot)
    }
    
}
