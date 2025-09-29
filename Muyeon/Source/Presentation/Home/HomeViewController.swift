//
//  HomeViewController.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

import RxSwift
import RxCocoa
import Wisp

class HomeViewController: UIViewController {
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<HomeView.Section, HomeUIModel>
    typealias DiffableSnapshot = NSDiffableDataSourceSnapshot<HomeView.Section, HomeUIModel>
    typealias CellProvider = DiffableDataSource.CellProvider
    typealias SupplementaryViewProvider = DiffableDataSource.SupplementaryViewProvider
    typealias TopTenCellRegistration = UICollectionView.CellRegistration<HomeTopTenCell, HomeUIModel>
    typealias TopTenHeaderRegistration = UICollectionView.SupplementaryRegistration<HomeTopTenHeaderView>
    typealias GenreCellRegistration = UICollectionView.CellRegistration<HomeBoxOfficeGenreCell, HomeUIModel>
    typealias TrendingCellRegistration = UICollectionView.CellRegistration<HomeTrendingCell, HomeUIModel>
    typealias TrendingHeaderRegistration = UICollectionView.SupplementaryRegistration<HomeTrendingHeaderView>
    
    private let topTenLoadingTrigger = PublishRelay<Void>()
    private let trendingLoadingTrigger = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    private let viewModel = HomeViewModel(
        fetchBoxOfficeUseCase: DefaultFetchBoxOfficeUseCase(),
        fetchPerformanceListUseCase: DefaultFetchPerformanceListUseCase()
    )
    
    private var dataSource: DiffableDataSource!
    
    private let rootView = HomeView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        setupCollectionView()
        bind()
        
        topTenLoadingTrigger.accept(())
        trendingLoadingTrigger.accept(())
    }
    
}


private extension HomeViewController {
    
    func bind() {
        let input = HomeViewModel.Input(
            topTenLoadingTrigger: topTenLoadingTrigger.asObservable(),
            trendingLoadingTrigger: trendingLoadingTrigger.asObservable(),
            itemSelected: rootView.homeCollectionView.rx.itemSelected
        )
        
        let output = viewModel.transform(input: input)
        
        let topTenContents = output.topTenContents
        let boxOfficeGenres = output.boxOfficeGenres
        let trendingContents = output.trendingContents
        
        Observable.combineLatest(topTenContents, boxOfficeGenres, trendingContents)
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, values in
                    var snapshot = DiffableSnapshot()
                    snapshot.appendSections(HomeView.Section.allCases)
                    snapshot.appendItems(values.0.map { HomeUIModel.topTen(model: $0) }, toSection: .topTen)
                    snapshot.appendItems(values.1.map { HomeUIModel.genre(model: $0) }, toSection: .genre)
                    snapshot.appendItems(values.2.map { HomeUIModel.trending(model: $0) }, toSection: .trending)
                    owner.dataSource.apply(snapshot)
                }
            )
            .disposed(by: disposeBag)
        
        output.presentDetail
            .bind(
                with: self,
                onNext: { owner, indexPath in
                    let naviCon = UINavigationController(rootViewController: PerformanceDetailViewController())
                    let wispConfig = WispConfiguration { config in
                        config.setGesture { gesture in
                            gesture.allowedDirections = [.right, .down]
                        }
                        config.setLayout { layout in
                            layout.initialCornerRadius = 5
                        }
                    }
                    
                    owner.wisp.present(
                        naviCon,
                        collectionView: owner.rootView.homeCollectionView,
                        at: indexPath,
                        configuration: wispConfig
                    )
                }
            )
            .disposed(by: disposeBag)
    }
    
}


private extension HomeViewController {
    
    func setupCollectionView() {
        let topTenCellRegistration = TopTenCellRegistration { cell, indexPath, itemIdentifier in
            // configuring Cell...
            cell.configure(with: itemIdentifier)
        }
        
        let genreCellRegistration = GenreCellRegistration { cell, indexPath, itemIdentifier in
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
            case 1:
                return collectionView.dequeueConfiguredReusableCell(
                    using: genreCellRegistration,
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
            case 1:
                return collectionView.dequeueConfiguredReusableSupplementary(using: trendingHeaderRegistration, for: indexPath)
            default:
                return nil
            }
        }
    }
    
}
