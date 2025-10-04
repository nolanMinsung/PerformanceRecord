//
//  SearchViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/1/25.
//

import UIKit

import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    // MARK: - Type Alias
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Performance>
    typealias CellProvider = DiffableDataSource.CellProvider
    typealias CellRegistration = UICollectionView.CellRegistration<SearchPerformanceCell, Performance>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Performance>
    
    
    enum Section {
        case main
    }
    
    private var diffableDataSource: DiffableDataSource!
    private let rootView = SearchView()
    private let viewModel = SearchViewModel(
        fetchPerformanceListUseCase: DefaultFetchPerformanceListUseCase()
    )
    
    private let genreSelected = BehaviorRelay<Constant.Genre?>(value: nil)
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = rootView
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        bind()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func setupCollectionView() {
        let cellRegistration = CellRegistration { cell, indexPath, performance in
            cell.configure(with: performance)
        }
        
        let searchResultCellProvider: CellProvider = { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        diffableDataSource = .init(
            collectionView: rootView.performanceCollectionView,
            cellProvider: searchResultCellProvider
        )
    }
    
    private func bind() {
        rootView.performanceCollectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                guard let selectedPerformance = owner.diffableDataSource.itemIdentifier(for: indexPath) else {
                    return
                }
                let detailVC = PerformanceDetailViewController(
                    performanceID: selectedPerformance.id,
                    posterURL: selectedPerformance.posterURL
                )
                detailVC.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        rootView.genreSelectionButton.menu = UIMenu(children: makeGenreButtonActions())
        
        let textFieldEndOnExit = rootView.searchTextField.rx.controlEvent(.editingDidEndOnExit)
        let searchButtonTapped = rootView.searchButton.rx.tap
        let searchTried = Observable.merge([textFieldEndOnExit.asObservable(), searchButtonTapped.asObservable()])
            .withLatestFrom(rootView.searchTextField.rx.text.orEmpty)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .share(replay: 1)
        
        let input = SearchViewModel.Input(
            searchTried: searchTried,
            fromDate: rootView.fromDatePicker.rx.date.asObservable(),
            toDate: rootView.toDatePicker.rx.date.asObservable(),
            genreSelected: genreSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.genreselected
            .map { $0?.description ?? "전체" }
            .bind(to: rootView.genreSelectionButton.rx.title())
            .disposed(by: disposeBag)
        
        output.fromDate
            .bind(to: rootView.fromDatePicker.rx.date)
            .disposed(by: disposeBag)
        
        output.performanceSearchResult
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, searchedResult in
                owner.applySnapshot(with: searchedResult)
            }
            .disposed(by: disposeBag)
        
        output.error
            .bind { print($0.localizedDescription) }
            .disposed(by: disposeBag)
    }
    
    private func applySnapshot(with searchResults: [Performance]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(searchResults, toSection: .main)
        diffableDataSource.apply(snapshot)
    }
    
    private func makeGenreButtonActions() -> [UIAction] {
        var menuElements = Constant.Genre.allCases.filter { $0 != .unknown }.map { genre in
            return UIAction(title: genre.description) { [weak self] _ in
                guard let self else { return }
                self.genreSelected.accept(genre)
            }
        }
        menuElements.insert(
            .init(title: "전체", handler: { [weak self] _ in
                guard let self else { return }
                self.genreSelected.accept(nil)
            }),
            at: 0
        )
        
        return menuElements
    }
    
}

// MARK: - Making Dummy Data
private extension SearchViewController {
    
    func makeDummy() -> [Performance] {
        return [
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [대전]",
                startDate: .now.addingTimeInterval(60),
                endDate: .now.addingTimeInterval(70),
                facilityFullName: "대전컨벤션센터 (DCC)",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF275317_250930_105134.gif".convertURLToHTTPS(),
                area: .daejeon,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [광주]",
                startDate: .now.addingTimeInterval(-2),
                endDate: .now,
                facilityFullName: "김대중컨벤션센터",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF274911_250924_145850.gif".convertURLToHTTPS(),
                area: .gwangju,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF273749<",
                name: "임영웅 콘서트: IM HERO TOUR [서울]",
                startDate: .now.addingTimeInterval(+20),
                endDate: .now.addingTimeInterval(+40),
                facilityFullName: "올림픽공원",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF273749_250910_114559.gif".convertURLToHTTPS(),
                area: .seoul,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [대전]",
                startDate: .now.addingTimeInterval(60),
                endDate: .now.addingTimeInterval(70),
                facilityFullName: "대전컨벤션센터 (DCC)",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF275317_250930_105134.gif".convertURLToHTTPS(),
                area: .daejeon,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [광주]",
                startDate: .now.addingTimeInterval(-2),
                endDate: .now,
                facilityFullName: "김대중컨벤션센터",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF274911_250924_145850.gif".convertURLToHTTPS(),
                area: .gwangju,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF273749<",
                name: "임영웅 콘서트: IM HERO TOUR [서울]",
                startDate: .now.addingTimeInterval(+20),
                endDate: .now.addingTimeInterval(+40),
                facilityFullName: "올림픽공원",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF273749_250910_114559.gif".convertURLToHTTPS(),
                area: .seoul,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [대전]",
                startDate: .now.addingTimeInterval(60),
                endDate: .now.addingTimeInterval(70),
                facilityFullName: "대전컨벤션센터 (DCC)",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF275317_250930_105134.gif".convertURLToHTTPS(),
                area: .daejeon,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [광주]",
                startDate: .now.addingTimeInterval(-2),
                endDate: .now,
                facilityFullName: "김대중컨벤션센터",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF274911_250924_145850.gif".convertURLToHTTPS(),
                area: .gwangju,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF273749<",
                name: "임영웅 콘서트: IM HERO TOUR [서울]",
                startDate: .now.addingTimeInterval(+20),
                endDate: .now.addingTimeInterval(+40),
                facilityFullName: "올림픽공원",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF273749_250910_114559.gif".convertURLToHTTPS(),
                area: .seoul,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [대전]",
                startDate: .now.addingTimeInterval(60),
                endDate: .now.addingTimeInterval(70),
                facilityFullName: "대전컨벤션센터 (DCC)",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF275317_250930_105134.gif".convertURLToHTTPS(),
                area: .daejeon,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF274911",
                name: "임영웅 콘서트: IM HERO TOUR [광주]",
                startDate: .now.addingTimeInterval(-2),
                endDate: .now,
                facilityFullName: "김대중컨벤션센터",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF274911_250924_145850.gif".convertURLToHTTPS(),
                area: .gwangju,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),
            .init(
                id: "PF273749<",
                name: "임영웅 콘서트: IM HERO TOUR [서울]",
                startDate: .now.addingTimeInterval(+20),
                endDate: .now.addingTimeInterval(+40),
                facilityFullName: "올림픽공원",
                posterURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF273749_250910_114559.gif".convertURLToHTTPS(),
                area: .seoul,
                genre: .popularMusic,
                openRun: false,
                state: .scheduled,
                detail: nil
            ),

        ]
    }
    
}
