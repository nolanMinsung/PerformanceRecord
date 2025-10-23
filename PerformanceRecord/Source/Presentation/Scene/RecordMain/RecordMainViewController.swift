//
//  RecordMainViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import RxSwift
import RxCocoa

class RecordMainViewController: UIViewController {
    
    private var headerData = RecordMainViewModel.HeaderData()
    
    private let rootView = RecordMainView()
    private let container: DIContainer
    private let viewModel: RecordMainViewModel
    private let addRecordVCTransitioningDelegate = AddRecordViewTransitioningDelegate()
    private let infoCardViewTapped = PublishRelay<Performance>()
    private let favoritesButtonTapped = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Properties
    private let recordsUpdateTrigger = PublishRelay<Void>()
    private var records: [Record] = []
    private var performancesWithRecords: [Performance] = []
    
    init(container: DIContainer) {
        self.container = container
        viewModel = RecordMainViewModel(
            fetchLikePerformanceListUseCase: container.resolve(type: FetchLikePerformanceListUseCase.self),
            fetchLocalPerformanceListUseCase: container.resolve(type: FetchLocalPerformanceListUseCase.self),
            fetchPerformanceDetailUseCase: container.resolve(type: FetchLocalPerformanceDetailUseCase.self),
            fetchMostViewedPerformanceUseCase: container.resolve(type: FetchMostViewedPerformanceUseCase.self),
            fetchAllRecordsUseCase: container.resolve(type: FetchAllRecordsUseCase.self)
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
        
        rootView.collectionView.dataSource = self
        rootView.collectionView.delegate = self
        navigationController?.navigationBar.isHidden = true
        bind()
        recordsUpdateTrigger.accept(())
    }
    
    private func bind() {
        DefaultRecordRepository.shared.recordUpdated
            .bind(with: self) { owner, _ in
                owner.recordsUpdateTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        let input = RecordMainViewModel.Input(
            updateRecords: recordsUpdateTrigger.asObservable(),
            favoritesButtonTapped: favoritesButtonTapped.asObservable(),
            infoCardTapped: infoCardViewTapped.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.allRecords
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, records in
                    owner.records = records
                    let totalRecords = records.count
                    let uniquePerformanceIDs = Set(records.map { $0.performanceID })
                    let averageRating = records.isEmpty ? 0 : records.map { $0.rating }.reduce(0, +) / Double(records.count)
                    let thisYearCount = records.filter { $0.viewedAt.isThisYear }.count
                    let photoCount = records.flatMap { $0.recordImageUUIDs }.count
                    
                    owner.headerData.stats = (totalRecords, uniquePerformanceIDs.count, averageRating, thisYearCount, photoCount)
                    owner.rootView.collectionView.reloadData()
                })
            .disposed(by: disposeBag)
        
        output.recentRecord
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, data in
                owner.headerData.recentRecord = data
            }
            .disposed(by: disposeBag)
        
        output.mostViewedPerformance
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, performance in
                owner.headerData.mostViewed = performance
            })
            .disposed(by: disposeBag)
        
        output.performancesWithRecord
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, performancesWithRecords in
                owner.performancesWithRecords = performancesWithRecords
                owner.rootView.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.showAddRecordView
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, likePerformances in
                    owner.showAddRecordFlow(performances: likePerformances)
                }
            )
            .disposed(by: disposeBag)
        
        output.infoCardTapped
            .bind(
                with: self,
                onNext: { owner, performance in
                    let recordDetailVC = RecordDetailViewController(
                        performance: performance,
                        container: owner.container
                    )
                    recordDetailVC.hidesBottomBarWhenPushed = true
                    owner.navigationController?.pushViewController(recordDetailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.errorRelay
            .bind {
                print($0.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    private func reloadHeader() {
        DispatchQueue.main.async {
            self.rootView.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
}


// MARK: - UICollectionViewDataSource
extension RecordMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return performancesWithRecords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PerformanceRecordCell.reuseIdentifier, for: indexPath) as? PerformanceRecordCell else {
            return UICollectionViewCell()
        }
        let performance = performancesWithRecords[indexPath.item]
        let relatedRecords = records.filter { $0.performanceID == performance.id }
        cell.configure(performance: performance, records: relatedRecords)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError()
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PerformanceRecordHeaderView.reuseIdentifier,
            for: indexPath
        ) as? PerformanceRecordHeaderView else {
            fatalError()
        }
        
        header.configureStats(
            totalCount: headerData.stats?.totalCount ?? 0,
            performanceCount: headerData.stats?.performanceCount ?? 0,
            averageRating: headerData.stats?.averageRating ?? 0.0,
            thisYearCount: headerData.stats?.thisYearCount ?? 0,
            photoCount: headerData.stats?.photoCount ?? 0
        )
        
        header.configureRecentRecord(recentRecordInfo: headerData.recentRecord)
        header.recentViewCard.rx.controlEvent(.touchUpInside)
            .compactMap { [weak self] in return self?.headerData.recentRecord?.performance }
            .bind(to: infoCardViewTapped)
            .disposed(by: header.disposeBag)
        
        header.configureMostViewed(mostViewedPerformance: headerData.mostViewed)
        header.mostViewedCard.rx.controlEvent(.touchUpInside)
            .compactMap { [weak self] in return self?.headerData.mostViewed }
            .bind(to: infoCardViewTapped)
            .disposed(by: header.disposeBag)
        
        header.favoritesButton.rx.tap
            .bind(to: favoritesButtonTapped)
            .disposed(by: header.disposeBag)
        
        return header
    }
}


extension RecordMainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let performance = performancesWithRecords[indexPath.item]
        let recordDetailVC = RecordDetailViewController(performance: performance, container: container)
        recordDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(recordDetailVC, animated: true)
    }
    
}


private extension RecordMainViewController {
    
    func loadSampleData() -> [Record] {
        // React 코드의 샘플 데이터를 Swift 모델로 변환
        let p1 = Performance(
            id: "perf_1",
            name: "레미제라블",
            startDate: .now.addingDay(-30),
            endDate: .now.addingDay(-4),
            facilityFullName: "샤롯데씨어터",
            posterURL: "",
            posterImageID: nil,
            area: .seoul,
            genre: .musical,
            openRun: false,
            state: .completed,
            records: [],
            detail: nil
        )
        let p2 = Performance(
            id: "perf_2",
            name: "BTS WORLD TOUR",
            startDate: .now.addingDay(-10),
            endDate: .now.addingDay(-1),
            facilityFullName: "잠실종합운동장",
            posterURL: "",
            posterImageID: nil,
            area: .seoul,
            genre: .popularMusic,
            openRun: false,
            state: .completed,
            records: [],
            detail: nil
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return [
            Record(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-06-20")!,
                rating: 4.5,
                reviewText: "두 번째 관람이었는데 첫 번째만큼 감동적이지는 않았지만 여전히 좋았다. 다른 배우들의 연기를 볼 수 있어서 좋았다.",
                recordImageUUIDs: []
            ),
            Record(
                id: UUID().uuidString,
                performanceID: p2.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-10-01")!,
                rating: 5.0,
                reviewText: "평생 잊지 못할 경험! 아미들과 함께 떼창하는 순간이 최고였다. 무대 연출도 정말 화려했다.",
                recordImageUUIDs: []
            ),
            Record(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-03-15")!,
                rating: 5.0,
                reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.",
                recordImageUUIDs: []
            )
        ]
    }
    
}


extension RecordMainViewController: SelectPerformanceDelegate {
    
    func showAddRecordFlow(performances: [Performance]) {
        let selectVC = SelectPerformanceViewController(performances: performances)
        selectVC.delegate = self
        selectVC.sheetPresentationController?.detents = [.medium(), .large()]
        selectVC.sheetPresentationController?.prefersGrabberVisible = true
        selectVC.sheetPresentationController?.preferredCornerRadius = 25
        present(selectVC, animated: true)
    }
    
    // MARK: - SelectPerformanceDelegate
    func didSelectPerformance(_ performance: Performance) {
        let addRecordVC = AddRecordViewController(performance: performance, container: container)
        addRecordVC.modalPresentationStyle = .custom
        addRecordVC.transitioningDelegate = addRecordVCTransitioningDelegate
        present(addRecordVC, animated: true)
    }
}
