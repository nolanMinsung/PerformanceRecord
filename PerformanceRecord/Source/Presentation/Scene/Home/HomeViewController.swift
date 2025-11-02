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
    private let container: DIContainer
    private var viewModel: HomeViewModel
    private var blurAnimator: UIViewPropertyAnimator? = nil
    
    private var dataSource: DiffableDataSource!
    
    private let rootView = HomeView()
    
    init(container: DIContainer) {
        self.container = container
        self.viewModel = HomeViewModel(
            fetchBoxOfficeUseCase: container.resolve(type: FetchBoxOfficeUseCase.self),
            fetchPerformanceListUseCase: container.resolve(type: FetchRemotePerformanceListUseCase.self)
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        wisp.delegate = self
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
        
        output.trendingContentsLoadingState
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, loadingState in
                UIView.animate(withDuration: 0.2) {
                    owner.rootView.homeCollectionView.contentInset.bottom = loadingState ? 500 : 0
                }
            })
            .disposed(by: disposeBag)
        
        rootView.homeCollectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                if indexPath.section == 1 {
                    guard let selectedIndexPaths = owner.rootView.homeCollectionView.indexPathsForSelectedItems else { return }
                    let oldSelectedGenreIndexPath = selectedIndexPaths.filter { $0.section == 1 && $0 != indexPath }
                    for oldIndexPath in oldSelectedGenreIndexPath {
                        owner.rootView.homeCollectionView.deselectItem(at: oldIndexPath, animated: true)
                    }
                } else {
                    owner.rootView.homeCollectionView.deselectItem(at: indexPath, animated: false)
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
            posterThumbnail: thumbnail,
            container: container
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
            startBlurAnimation(duration: 0.5)
            wisp.present(
                naviCon,
                collectionView: rootView.homeCollectionView,
                at: indexPath,
                configuration: wispConfig
            )
        }
    }
    
}



// MARK: - Blur Animation
private extension HomeViewController {
    
    func startBlurAnimation(duration: TimeInterval) {
        if let blurAnimator {
            blurAnimator.stopAnimation(true)
            blurAnimator.finishAnimation(at: .current)
            self.blurAnimator = nil
            self.rootView.blurView.effect = nil
        }
        let createdBlurAnimator = UIViewPropertyAnimator(
            duration: duration * 4,
            controlPoint1: .init(x: 0.2, y: 0.5),
            controlPoint2: .init(x: 0.7, y: 0.0)
        )
        
        createdBlurAnimator.addAnimations { [weak self] in
            guard let self else { return }
            self.rootView.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        self.blurAnimator = createdBlurAnimator
        createdBlurAnimator.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self else { return }
            guard let blurAnimator else { return }
            guard !blurAnimator.isReversed else { return }
            blurAnimator.pauseAnimation()
        }
    }
    
    func startBlurRemoving() {
        guard let blurAnimator else {
            self.rootView.blurView.effect = nil
            return
        }
        blurAnimator.pauseAnimation()
        blurAnimator.isReversed = true
        let springTimingParameter = UISpringTimingParameters(dampingRatio: 1)
        if blurAnimator.state == .active {
            blurAnimator.continueAnimation(withTimingParameters: springTimingParameter, durationFactor: 0.25)
        } else {
            // 앱을 나갔다 들어오거나 화면을 껐다 킨 경우 -> animator의 state가 .active가 아님
            // (pause해놓은 설정이 풀리며 completionHandler 호출)
            UIView.springAnimate(withDuration: 0.5) { [weak self] in
                guard let self else { return }
                self.rootView.blurView.effect = nil
            }
        }
    }
    
}


// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        return true
    }
        
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true,
           indexPath.section == 1
        {
            return false
        }
        return true
    }
    
}


// MARK: - WispPresenterDelegate
extension HomeViewController: WispPresenterDelegate {
    
    func wispWillRestore() {
        startBlurRemoving()
    }
    
}
