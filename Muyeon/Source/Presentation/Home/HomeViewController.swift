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
        fetchPerformanceListUseCase: DefaultFetchRemotePerformanceListUseCase()
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
        
        rootView.homeCollectionView.selectItem(at: IndexPath(item: 0, section: 1), animated: false, scrollPosition: .init())
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
                    snapshot.appendItems(Array(values.0.map { HomeUIModel.topTen(model: $0) }.prefix(10)), toSection: .topTen)
                    snapshot.appendItems(values.1.map { HomeUIModel.genre(model: $0) }, toSection: .genre)
                    snapshot.appendItems(values.2.map { HomeUIModel.trending(model: $0) }, toSection: .trending)
                    owner.dataSource.apply(snapshot)
                }
            )
            .disposed(by: disposeBag)
        
        rootView.homeCollectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let currentSection = indexPath.section
                guard let selectedIndexPaths = owner.rootView.homeCollectionView.indexPathsForSelectedItems else { return }
                let selectedSameSection = selectedIndexPaths.filter {
                    $0.section == currentSection && $0 != indexPath
                }
                for oldIndexPath in selectedSameSection {
                    owner.rootView.homeCollectionView.deselectItem(at: oldIndexPath, animated: true)
                }
                
            })
            .disposed(by: disposeBag)
        
        
        rootView.homeCollectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                guard let selectedItem = owner.dataSource.itemIdentifier(for: indexPath) else {
                    return
                }
                let boxOfficeItem: BoxOfficeItem
                var selectedItemImage: UIImage? = nil
                switch selectedItem {
                case .topTen(let model):
                    boxOfficeItem = model
                    selectedItemImage = (owner.rootView.homeCollectionView.cellForItem(at: indexPath) as? HomeTopTenCell)?.imageView.image
                    owner.presentDetailVC(
                        performanceID: boxOfficeItem.id,
                        posterURL: boxOfficeItem.posterURL,
                        thumbnail: selectedItemImage,
                        style: .modal
                    )
                case .trending(let model):
                    boxOfficeItem = model
                    selectedItemImage = (owner.rootView.homeCollectionView.cellForItem(at: indexPath) as? HomeTrendingCell)?.imageView.image
                    owner.presentDetailVC(
                        performanceID: boxOfficeItem.id,
                        posterURL: boxOfficeItem.posterURL,
                        thumbnail: selectedItemImage,
                        style: .wisp(indexPath: indexPath)
                    )
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
    }
    
}


private extension HomeViewController {
    
    func setupCollectionView() {
        rootView.homeCollectionView.delegate = self
        let topTenCellRegistration = TopTenCellRegistration { cell, indexPath, itemIdentifier in
            cell.configure(with: itemIdentifier)
        }
        let genreCellRegistration = GenreCellRegistration { cell, indexPath, itemIdentifier in
            cell.configure(with: itemIdentifier)
        }
        let trendingCellRegistration = TrendingCellRegistration { cell, indexPath, itemIdentifier in
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
    
    
    enum DetailViewPresentStyle {
        case modal
        case wisp(indexPath: IndexPath)
    }
    
    func presentDetailVC(performanceID: String, posterURL: String, thumbnail: UIImage? = nil, style: DetailViewPresentStyle) {
        let performanceDetailVC = PerformanceDetailViewController(
            performanceID: performanceID,
            posterURL: posterURL,
            posterThumbnail: thumbnail
        )
        let naviCon = UINavigationController(rootViewController: performanceDetailVC)
        
        switch style {
        case .modal:
            present(naviCon, animated: true)
        case .wisp(let indexPath):
            let wispConfig = WispConfiguration { config in
                config.setGesture { gesture in
                    gesture.allowedDirections = [.right, .down]
                }
                config.setLayout { layout in
                    let topInset = self.view.safeAreaInsets.top
                    layout.presentedAreaInset = .init(top: topInset, left: 0, bottom: 0, right: 0)
                    layout.initialCornerRadius = 5
                }
            }
            wisp.present(
                naviCon,
                collectionView: rootView.homeCollectionView,
                at: indexPath,
                configuration: wispConfig
            )
        }
    }
    
}


extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        return true
    }
    
    
}
