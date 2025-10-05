//
//  PerformanceDetailViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import Foundation

import RxSwift
import RxCocoa

final class PerformanceDetailViewModel {
    
    struct Input {
        let likeButtonTapped: Observable<Bool>
        let facilityButtonTapped: Observable<String>
    }
    
    struct Output {
        let posterURL: Observable<String>
        let performanceDetail: Observable<Performance>
        let showFacilityDetail: Observable<String>
        let likeButtonSelectionState: Observable<Bool>
        let error: Observable<any Error>
    }
    
    let performanceID: String
    let posterURL: String
    let fetchPerformanceDetailUseCase: any FetchPerformanceDetailUseCase
    let togglePerformanceLikeUseCase: any TogglePerformanceLikeUseCase
    let savePerformanceUseCase: any SavePerformanceUseCase
    let deletePerformanceUseCase: any DeletePerformanceUseCase
    private let disposeBag = DisposeBag()
    
    init(
        performanceID: String,
        posterURL: String,
        fetchPerformanceDetailUseCase: FetchPerformanceDetailUseCase,
        togglePerformanceLikeUseCase: TogglePerformanceLikeUseCase,
        savePerformanceUseCase: SavePerformanceUseCase,
        deletePerformanceUseCase: DeletePerformanceUseCase
    ) {
        self.performanceID = performanceID
        self.posterURL = posterURL
        self.fetchPerformanceDetailUseCase = fetchPerformanceDetailUseCase
        self.togglePerformanceLikeUseCase = togglePerformanceLikeUseCase
        self.savePerformanceUseCase = savePerformanceUseCase
        self.deletePerformanceUseCase = deletePerformanceUseCase
    }
    
    func transform(input: Input) -> Output {
        let performanceDetail = PublishRelay<Performance>()
        let showFacilityDetail = PublishRelay<String>()
        let likeButtonStatusRelay = PublishRelay<Bool>()
        let errorRelay = PublishRelay<any Error>()
        
        Task {
            let performanceDetailInfo = try await fetchPerformanceDetailUseCase.execute(performanceID: performanceID)
            performanceDetail.accept(performanceDetailInfo)
        }
        
        input.likeButtonTapped
            .withLatestFrom(performanceDetail)
            .bind(with: self) { owner, performance in
                Task {
                    do {
                        let newLikeStatus = owner.togglePerformanceLikeUseCase.execute(performanceID: owner.performanceID)
                        if newLikeStatus {
                            try await self.savePerformanceUseCase.execute(performance: performance)
                        } else {
                            try await self.deletePerformanceUseCase.execute(performance: performance)
                        }
                        likeButtonStatusRelay.accept(newLikeStatus)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.facilityButtonTapped
            .withLatestFrom(performanceDetail)
            .compactMap(\.detail?.facilityID)
            .bind(to: showFacilityDetail)
            .disposed(by: disposeBag)
        
        return .init(
            posterURL: Observable<String>.just(posterURL),
            performanceDetail: performanceDetail.asObservable(),
            showFacilityDetail: showFacilityDetail.asObservable(),
            likeButtonSelectionState: likeButtonStatusRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
    
}
