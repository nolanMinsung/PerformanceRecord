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
        let showAddRecordView: Observable<[Performance]>
        let errorRelay: PublishRelay<any Error>
    }
    
    private let fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase
    private let fetchAllDiariesUseCase: any FetchAllDiariesUseCase
    private let disposeBag = DisposeBag()
    
    init(
        fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase,
        fetchDiariesUseCase: any FetchAllDiariesUseCase
    ) {
        self.fetchLikePerformanceListUseCase = fetchLikePerformanceListUseCase
        self.fetchAllDiariesUseCase = fetchDiariesUseCase
    }
    
    func transform(input: Input) -> Output {
        let allDiariesRelay = PublishRelay<[Diary]>()
        let likePerformanceListRelay = PublishRelay<[Performance]>()
        let errorRelay = PublishRelay<any Error>()
        
        input.updateDiaries
            .bind { _ in
                Task {
                    do {
                        let allDiaries = try await self.fetchAllDiariesUseCase.execute()
                        allDiariesRelay.accept(allDiaries)
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
            allDiaries: allDiariesRelay.asObservable(),
            showAddRecordView: likePerformanceListRelay.asObservable(),
            errorRelay: errorRelay
        )
    }
    
}
