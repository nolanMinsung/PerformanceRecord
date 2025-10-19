//
//  RecordMainViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

import RxSwift
import RxCocoa

final class RecordMainViewModel {
    
    struct Input {
        let updateRecords: Observable<Void>
        let favoritesButtonTapped: Observable<Void>
        let infoCardTapped: Observable<Performance>
    }
    
    struct Output {
        let allRecords: Observable<[Record]>
        let recentRecord: Observable<(record: Record?, performance: Performance)>
        let mostViewedPerformance: Observable<Performance>
        let performancesWithRecord: Observable<[Performance]>
        let showAddRecordView: Observable<[Performance]>
        let infoCardTapped: Observable<Performance>
        let errorRelay: PublishRelay<any Error>
    }
    
    private let fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase
    private let fetchLocalPerformanceListUseCase: any FetchLocalPerformanceListUseCase
    private let fetchLocalPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase
    private let fetchMostViewedPerformanceUseCase: any FetchMostViewedPerformanceUseCase
    private let fetchAllRecordsUseCase: any FetchAllRecordsUseCase
    private let disposeBag = DisposeBag()
    
    init(
        fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase,
        fetchLocalPerformanceListUseCase: any FetchLocalPerformanceListUseCase,
        fetchPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase,
        fetchMostViewedPerformanceUseCase: any FetchMostViewedPerformanceUseCase,
        fetchAllRecordsUseCase: any FetchAllRecordsUseCase
    ) {
        self.fetchLikePerformanceListUseCase = fetchLikePerformanceListUseCase
        self.fetchLocalPerformanceListUseCase = fetchLocalPerformanceListUseCase
        self.fetchLocalPerformanceDetailUseCase = fetchPerformanceDetailUseCase
        self.fetchMostViewedPerformanceUseCase = fetchMostViewedPerformanceUseCase
        self.fetchAllRecordsUseCase = fetchAllRecordsUseCase
    }
    
    func transform(input: Input) -> Output {
        let allRecordsRelay = PublishRelay<[Record]>()
        let recentRecordRelay = PublishRelay<(record: Record?, performance: Performance)>()
        let mostViewedPerformanceRelay = PublishRelay<Performance>()
        let performancesWithRecordsRelay = PublishRelay<[Performance]>()
        let likePerformanceListRelay = PublishRelay<[Performance]>()
        let errorRelay = PublishRelay<any Error>()
        
        input.updateRecords
            .bind { _ in
                Task {
                    do {
                        let allRecords = try await self.fetchAllRecordsUseCase.execute()
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
        
        input.favoritesButtonTapped
            .bind { _ in
                Task {
                    do {
                        let likePerformances = try await self.fetchLikePerformanceListUseCase.execute()
                        likePerformanceListRelay.accept(likePerformances)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
            
        return .init(
            allRecords: allRecordsRelay.asObservable(),
            recentRecord: recentRecordRelay.asObservable(),
            mostViewedPerformance: mostViewedPerformanceRelay.asObservable(),
            performancesWithRecord: performancesWithRecordsRelay.asObservable(),
            showAddRecordView: likePerformanceListRelay.asObservable(),
            infoCardTapped: input.infoCardTapped,
            errorRelay: errorRelay
        )
    }
    
}
