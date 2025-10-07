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
        fetchDiariesUseCase: DefaultFetchAllDiariesUseCase(
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
    
    
    // MARK: - Data Handling
    private func configureData(diaries: [Diary]) {
        // 통계 데이터 설정 -> 뷰모델로 옮기기
        let totalRecords = diaries.count
        let uniquePerformances = Set(diaries.compactMap { $0.performance })
        let averageRating = diaries.isEmpty ? 0 : diaries.map { $0.rating }.reduce(0, +) / Double(diaries.count)
        let thisYearCount = 0// diaries.filter { Calendar.current.isDateInThisYear($0.viewedAt) }.count
        let photoCount = diaries.flatMap { $0.diaryImageUUIDs }.count
        
        rootView.statsSummaryView.configure(
            totalCount: totalRecords,
            performanceCount: uniquePerformances.count,
            averageRating: averageRating,
            thisYearCount: thisYearCount,
            photoCount: photoCount
        )
        
        // 최근 관람 데이터 설정
        if let recentDiary = diaries.sorted(by: { $0.viewedAt > $1.viewedAt }).first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM월 dd일"
            rootView.recentViewCard.isHidden = false
            rootView.recentViewCard.configure(
                mainText: recentDiary.performance?.name ?? "",
                tagText: "★ \(recentDiary.rating)",
                tagColor: .systemOrange,
                subText: dateFormatter.string(from: recentDiary.viewedAt)
            )
        } else {
            rootView.recentViewCard.isHidden = true
        }
        
        // 최다 관람 데이터 설정
        let performanceCounts = diaries.reduce(into: [:]) { counts, diary in
            counts[diary.performance, default: 0] += 1
        }
        if let (mostViewed, count) = performanceCounts.max(by: { $0.value < $1.value }) {
            rootView.mostViewedCard.isHidden = false
            rootView.mostViewedCard.configure(
                mainText: mostViewed?.name ?? "",
                tagText: "\(count)회",
                tagColor: .systemIndigo,
                subText: mostViewed?.facilityFullName ?? ""
            )
        } else {
            rootView.mostViewedCard.isHidden = true
        }
        
        // 공연 기록 리스트 데이터 설정
        self.performancesWithRecords = Array(uniquePerformances).sorted(by: { p1, p2 in
            let latestDate1 = diaries.filter { $0.performance == p1 }.map { $0.viewedAt }.max() ?? Date.distantPast
            let latestDate2 = diaries.filter { $0.performance == p2 }.map { $0.viewedAt }.max() ?? Date.distantPast
            return latestDate1 > latestDate2
        })
        
        rootView.collectionView.reloadData()
        // 데이터 로드 후 높이를 업데이트 하기 위해 호출
        DispatchQueue.main.async {
            self.rootView.updateCollectionViewHeight()
        }
    }
    
    private func bind() {
        let input = PerformanceRecordViewModel.Input(
            updateDiaries: diariesUpdateTrigger.asObservable(),
            addRecordButtonTapped: rootView.addRecordButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.allDiaries
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, diaries in
                    owner.diaries = diaries
                    owner.rootView.collectionView.reloadData()
                    owner.configureData(diaries: diaries)
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
        let relatedRecords = diaries.filter { $0.performance?.id == performance.id }
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
            detail: nil
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return [
            Diary(performance: p1, createdAt: Date(), viewedAt: dateFormatter.date(from: "2024-06-20")!, rating: 4.5, reviewText: "두 번째 관람이었는데 첫 번째만큼 감동적이지는 않았지만 여전히 좋았다. 다른 배우들의 연기를 볼 수 있어서 좋았다.", diaryImageUUIDs: []),
            Diary(performance: p2, createdAt: Date(), viewedAt: dateFormatter.date(from: "2024-10-01")!, rating: 5.0, reviewText: "평생 잊지 못할 경험! 아미들과 함께 떼창하는 순간이 최고였다. 무대 연출도 정말 화려했다.", diaryImageUUIDs: []),
            Diary(performance: p1, createdAt: Date(), viewedAt: dateFormatter.date(from: "2024-03-15")!, rating: 5.0, reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.", diaryImageUUIDs: [])
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
