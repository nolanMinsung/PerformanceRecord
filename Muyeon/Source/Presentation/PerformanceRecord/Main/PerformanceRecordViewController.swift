//
//  PerformanceRecordViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import RxSwift
import RxCocoa

class PerformanceRecordViewController: UIViewController {
    
    private struct HeaderData {
        var stats: (totalCount: Int, performanceCount: Int, averageRating: Double, thisYearCount: Int, photoCount: Int)?
        var recentRecord: (record: Record?, performance: Performance)?
        var mostViewed: Performance?
    }
    
    private var headerData = HeaderData()
    
    private let rootView = PerformanceRecordView()
    private let viewModel = PerformanceRecordViewModel(
        fetchLikePerformanceListUseCase: DefaultFetchLikePerformanceListUseCase(
            performanceRepository: DefaultPerformanceRepository.shared
        ),
        fetchLocalPerformanceListUseCase: DefaultFetchLocalPerformanceListUseCase(
            performanceRepository: DefaultPerformanceRepository.shared
        ),
        fetchPerformanceDetailUseCase: DefaultFetchLocalPerformanceDetailUseCase(
            performanceRepository: DefaultPerformanceRepository.shared
        ),
        fetchMostViewedPerformanceUseCase: DefaultFetchMostViewedPerformanceUseCase(
            performanceRepository: DefaultPerformanceRepository.shared
        ),
        fetchAllRecordsUseCase: DefaultFetchAllRecordsUseCase(
            recordRepository: DefaultRecordRepository.shared
        )
    )
    private let addRecordButtonTap = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Properties
    private let recordsUpdateTrigger = PublishRelay<Void>()
    private var records: [Record] = []
    private var performancesWithRecords: [Performance] = []
    
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
            .bind(to: recordsUpdateTrigger)
            .disposed(by: disposeBag)
        
        let input = PerformanceRecordViewModel.Input(
            updateRecords: recordsUpdateTrigger.asObservable(),
            addRecordButtonTapped: addRecordButtonTap.asObservable()
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
                let (recentRecord, performance) = data
                owner.headerData.recentRecord = (recentRecord, performance)
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
extension PerformanceRecordViewController: UICollectionViewDataSource {
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
        
        if let stats = headerData.stats {
            header.configureStats(
                totalCount: stats.totalCount,
                performanceCount: stats.performanceCount,
                averageRating: stats.averageRating,
                thisYearCount: stats.thisYearCount,
                photoCount: stats.photoCount
            )
        }
        
        if let recentData = headerData.recentRecord {
            header.configureRecentRecord(recentRecord: recentData.record, performance: recentData.performance)
        }
        
        if let mostViewed = headerData.mostViewed {
            header.configureMostViewed(mostViewedPerformance: mostViewed)
        }
        
        header.addRecordButton.rx.tap
            .bind(to: addRecordButtonTap)
            .disposed(by: header.disposeBag)
        
        return header
    }
}


extension PerformanceRecordViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let performance = performancesWithRecords[indexPath.item]
        let vc = RecordDetailViewController(
            fetchLocalPosterUseCase: DefaultFetchLocalPosterUseCase(
                imageRepository: DefaultImageRepository.shared
            ),
            fetchLocalPerformanceDetailUseCase: DefaultFetchLocalPerformanceDetailUseCase(
                performanceRepository: DefaultPerformanceRepository.shared
            ),
            deleteRecordUseCase: DefaultDeleteRecordUseCase(
                recordRepository: DefaultRecordRepository.shared
            ),
            performance: performance
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


private extension PerformanceRecordViewController {
    
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


extension PerformanceRecordViewController: SelectPerformanceDelegate {
    
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
        let addRecordVC = AddRecordViewController(performance: performance)
        addRecordVC.onRecordDataChanged = { [weak self] in
            self?.recordsUpdateTrigger.accept(())
        }
        addRecordVC.modalPresentationStyle = .overFullScreen
        addRecordVC.modalTransitionStyle = .crossDissolve
        present(addRecordVC, animated: true)
    }
}
