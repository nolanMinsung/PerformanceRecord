//
//  PerformanceRecordViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

import RxSwift
import RxCocoa

final class PerformanceRecordViewModel {
    
    struct Input {
        let updateDiaries: Observable<Void>
        let addRecordButtonTapped: Observable<Void>
    }
    
    struct Output {
        let allDiaries: Observable<[Diary]>
        let recentRecord: Observable<(record: Diary?, performance: Performance)>
        let mostViewedPerformance: Observable<Performance>
        let performancesWithRecord: Observable<[Performance]>
        let showAddRecordView: Observable<[Performance]>
        let errorRelay: PublishRelay<any Error>
    }
    
    private let fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase
    private let fetchLocalPerformanceListUseCase: any FetchLocalPerformanceListUseCase
    private let fetchLocalPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase
    private let fetchMostViewedPerformanceUseCase: any FetchMostViewedPerformanceUseCase
    private let fetchAllDiariesUseCase: any FetchAllDiariesUseCase
    private let disposeBag = DisposeBag()
    
    init(
        fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase,
        fetchLocalPerformanceListUseCase: any FetchLocalPerformanceListUseCase,
        fetchPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase,
        fetchMostViewedPerformanceUseCase: any FetchMostViewedPerformanceUseCase,
        fetchAllDiariesUseCase: any FetchAllDiariesUseCase
    ) {
        self.fetchLikePerformanceListUseCase = fetchLikePerformanceListUseCase
        self.fetchLocalPerformanceListUseCase = fetchLocalPerformanceListUseCase
        self.fetchLocalPerformanceDetailUseCase = fetchPerformanceDetailUseCase
        self.fetchMostViewedPerformanceUseCase = fetchMostViewedPerformanceUseCase
        self.fetchAllDiariesUseCase = fetchAllDiariesUseCase
    }
    
    func transform(input: Input) -> Output {
        let allRecordsRelay = PublishRelay<[Diary]>()
        let recentRecordRelay = PublishRelay<(record: Diary?, performance: Performance)>()
        let mostViewedPerformanceRelay = PublishRelay<Performance>()
        let performancesWithRecordsRelay = PublishRelay<[Performance]>()
        let likePerformanceListRelay = PublishRelay<[Performance]>()
        let errorRelay = PublishRelay<any Error>()
        
        input.updateDiaries
            .bind { _ in
                Task {
                    do {
                        let allRecords = try await self.fetchAllDiariesUseCase.execute()
                        let recentRecord = allRecords.sorted(by: { $0.viewedAt > $1.viewedAt }).first
                        if let performanceID = recentRecord?.performanceID {
                            let detailPerformance = try await self.fetchLocalPerformanceDetailUseCase.execute(performanceID: performanceID)
                            recentRecordRelay.accept((record: recentRecord, performance: detailPerformance))
                        }
                        let allPerformances = try await self.fetchLocalPerformanceListUseCase.execute()
                        let mostViewedPerformance = try await self.fetchMostViewedPerformanceUseCase.execute()
                        mostViewedPerformanceRelay.accept(mostViewedPerformance)
                        allRecordsRelay.accept(allRecords)
                        
                        let performancesWithRecords = allPerformances.filter({ !$0.records.isEmpty }).sorted(by: { p1, p2 in
                            let latestDate1 = allRecords.filter { $0.performanceID == p1.id }.map { $0.viewedAt }.max() ?? Date.distantPast
                            let latestDate2 = allRecords.filter { $0.performanceID == p2.id }.map { $0.viewedAt }.max() ?? Date.distantPast
                            return latestDate1 > latestDate2
                        })
                        
                        performancesWithRecordsRelay.accept(performancesWithRecords)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.addRecordButtonTapped
            .bind { _ in
                Task {
                    do {
                        let likePerformances = try await self.fetchLikePerformanceListUseCase.execute()
                        // startDate이 아직 오지 않은 날짜인 경우, 기록 시 공연 명단에서 제외
                        let recordablePerformances = likePerformances.filter {
                            Calendar.current.compare($0.startDate, to: .now, toGranularity: .day) != .orderedDescending
                        }
                        likePerformanceListRelay.accept(recordablePerformances)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
            
        return .init(
            allDiaries: allRecordsRelay.asObservable(),
            recentRecord: recentRecordRelay.asObservable(),
            mostViewedPerformance: mostViewedPerformanceRelay.asObservable(),
            performancesWithRecord: performancesWithRecordsRelay.asObservable(),
            showAddRecordView: likePerformanceListRelay.asObservable(),
            errorRelay: errorRelay
        )
    }
    
}
