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
    private let disposeBag = DisposeBag()
    
    init(
        performanceID: String,
        posterURL: String,
        fetchPerformanceDetailUseCase: some FetchPerformanceDetailUseCase,
        togglePerformanceLikeUseCase: some TogglePerformanceLikeUseCase
    ) {
        self.performanceID = performanceID
        self.posterURL = posterURL
        self.fetchPerformanceDetailUseCase = fetchPerformanceDetailUseCase
        self.togglePerformanceLikeUseCase = togglePerformanceLikeUseCase
    }
    
    func transform(input: Input) -> Output {
        let performanceDetail = PublishRelay<Performance>()
        let showFacilityDetail = PublishRelay<String>()
        let likeButtonStatusRelay = PublishRelay<Bool>()
        let errorRelay = PublishRelay<any Error>()
        
        input.likeButtonTapped
            .bind(with: self) { owner, currentSelectionState in
                do {
                    try owner.togglePerformanceLikeUseCase.execute(performanceID: owner.performanceID)
                    likeButtonStatusRelay.accept(!currentSelectionState)
                } catch {
                    errorRelay.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.facilityButtonTapped
            .withLatestFrom(performanceDetail)
            .compactMap(\.detail?.facilityID)
            .bind(to: showFacilityDetail)
            .disposed(by: disposeBag)
        
        Task {
            let performanceDetailInfo = try await fetchPerformanceDetailUseCase.execute(performanceID: performanceID)
            performanceDetail.accept(performanceDetailInfo)
        }
        
        return .init(
            posterURL: Observable<String>.just(posterURL),
            performanceDetail: performanceDetail.asObservable(),
            showFacilityDetail: showFacilityDetail.asObservable(),
            likeButtonSelectionState: likeButtonStatusRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
    
}
