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
        fetchAllDiariesUseCase: DefaultFetchAllDiariesUseCase(
            diaryRepository: DefaultDiaryRepository.shared
        )
    )
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    private let diariesUpdateTrigger = PublishRelay<Void>()
    private var diaries: [Diary] = []
    private var performancesWithRecords: [Performance] = []
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collectionView.dataSource = self
        rootView.collectionView.delegate = self
        bind()
        diariesUpdateTrigger.accept(())
    }
    
    private func bind() {
        let input = PerformanceRecordViewModel.Input(
            updateDiaries: diariesUpdateTrigger.asObservable(),
            addRecordButtonTapped: rootView.addRecordButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.allDiaries
            .debug()
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, diaries in
                    owner.diaries = diaries
                    owner.rootView.collectionView.reloadData()
                    let totalRecords = diaries.count
                    let uniquePerformanceIDs = Set(diaries.map { $0.performanceID })
                    let averageRating = diaries.isEmpty ? 0 : diaries.map { $0.rating }.reduce(0, +) / Double(diaries.count)
                    let thisYearCount = 0// diaries.filter { Calendar.current.isDateInThisYear($0.viewedAt) }.count
                    let photoCount = diaries.flatMap { $0.diaryImageUUIDs }.count
                    owner.rootView.configureStats(
                        totalCount: totalRecords,
                        performanceCount: uniquePerformanceIDs.count,
                        averageRating: averageRating,
                        thisYearCount: thisYearCount,
                        photoCount: photoCount
                    )
                })
            .disposed(by: disposeBag)
        
        output.recentRecord
            .debug()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, data in
                let (recentRecord, performance) = data
                owner.rootView.configureRecentRecord(recentRecord: recentRecord, performance: performance)
            }
            .disposed(by: disposeBag)
        
        output.mostViewedPerformance
            .debug()
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, performance in
                owner.rootView.configureMostViewed(mostViewedPerformance: performance)
            })
            .disposed(by: disposeBag)
        
        output.performancesWithRecord
            .debug()
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, performancesWithRecords in
                owner.performancesWithRecords = performancesWithRecords
                owner.rootView.collectionView.reloadData()
                DispatchQueue.main.async {
                    owner.rootView.updateCollectionViewHeight()
                }
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
        let relatedRecords = diaries.filter { $0.performanceID == performance.id }
        cell.configure(performance: performance, records: relatedRecords)
        return cell
    }
}


extension PerformanceRecordViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = RecordDetailViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


private extension PerformanceRecordViewController {
    
    func loadSampleData() -> [Diary] {
        // React 코드의 샘플 데이터를 Swift 모델로 변환
        let p1 = Performance(
            id: "perf_1",
            name: "레미제라블",
            startDate: .now.addingDay(-30),
            endDate: .now.addingDay(-4),
            facilityFullName: "샤롯데씨어터",
            posterURL: "",
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
            Diary(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-06-20")!,
                rating: 4.5,
                reviewText: "두 번째 관람이었는데 첫 번째만큼 감동적이지는 않았지만 여전히 좋았다. 다른 배우들의 연기를 볼 수 있어서 좋았다.",
                diaryImageUUIDs: []
            ),
            Diary(
                id: UUID().uuidString,
                performanceID: p2.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-10-01")!,
                rating: 5.0,
                reviewText: "평생 잊지 못할 경험! 아미들과 함께 떼창하는 순간이 최고였다. 무대 연출도 정말 화려했다.",
                diaryImageUUIDs: []
            ),
            Diary(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-03-15")!,
                rating: 5.0,
                reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.",
                diaryImageUUIDs: []
            )
        ]
    }
    
}


extension PerformanceRecordViewController: SelectPerformanceDelegate {
    
    func showAddRecordFlow(performances: [Performance]) {
        let selectVC = SelectPerformanceViewController(performances: performances)
        selectVC.delegate = self
        selectVC.modalPresentationStyle = .overFullScreen
        selectVC.modalTransitionStyle = .crossDissolve
        present(selectVC, animated: true)
    }
    
    // MARK: - SelectPerformanceDelegate
    func didSelectPerformance(_ performance: Performance) {
        let addRecordVC = AddRecordViewController(performance: performance)
        addRecordVC.onDiaryDataChanged = { [weak self] in
            self?.diariesUpdateTrigger.accept(())
        }
        addRecordVC.modalPresentationStyle = .overFullScreen
        addRecordVC.modalTransitionStyle = .crossDissolve
        present(addRecordVC, animated: true)
    }
}
