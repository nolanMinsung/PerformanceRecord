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
        let addRecordButtonTapped: Observable<Void>
    }
    
    struct Output {
        let showAddRecordView: Observable<[Performance]>
        let errorRelay: PublishRelay<any Error>
    }
    
    private let fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase
    private let disposeBag = DisposeBag()
    
    init(fetchLikePerformanceListUseCase: any FetchLikePerformanceListUseCase) {
        self.fetchLikePerformanceListUseCase = fetchLikePerformanceListUseCase
    }
    
    func transform(input: Input) -> Output {
        let likePerformanceListRelay = PublishRelay<[Performance]>()
        let errorRelay = PublishRelay<any Error>()
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
            showAddRecordView: likePerformanceListRelay.asObservable(),
            errorRelay: errorRelay
        )
    }
    
}
