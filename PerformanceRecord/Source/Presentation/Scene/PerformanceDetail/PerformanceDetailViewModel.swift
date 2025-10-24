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
        let facilityButtonTapped: Observable<Void>
        let addRecordButtonTapped: Observable<Void>
    }
    
    struct Output {
        let posterURL: Observable<String>
        let performanceDetail: Observable<Performance>
        let showFacilityDetail: Observable<String>
        let likeButtonSelectionState: Observable<Bool>
        let showAddRecordVC: Observable<Performance>
        let error: Observable<any Error>
    }
    
    private let performanceID: String
    private let posterURL: String
    private let fetchRemotePerformanceDetailUseCase: any FetchRemotePerformanceDetailUseCase
    private let togglePerformanceLikeUseCase: any TogglePerformanceLikeUseCase
    private let disposeBag = DisposeBag()
    
    init(
        performanceID: String,
        posterURL: String,
        fetchRemotePerformanceDetailUseCase: FetchRemotePerformanceDetailUseCase,
        togglePerformanceLikeUseCase: TogglePerformanceLikeUseCase,
    ) {
        self.performanceID = performanceID
        self.posterURL = posterURL
        self.fetchRemotePerformanceDetailUseCase = fetchRemotePerformanceDetailUseCase
        self.togglePerformanceLikeUseCase = togglePerformanceLikeUseCase
    }
    
    func transform(input: Input) -> Output {
        let performanceDetail = PublishRelay<Performance>()
        let showFacilityDetail = PublishRelay<String>()
        let likeButtonStatusRelay = PublishRelay<Bool>()
        let showAddRecordVCRelay = PublishRelay<Performance>()
        let errorRelay = PublishRelay<any Error>()
        
        Task {
            let performanceDetailInfo = try await fetchRemotePerformanceDetailUseCase.execute(performanceID: performanceID)
            performanceDetail.accept(performanceDetailInfo)
        }
        
        input.likeButtonTapped
            .bind(with: self) { owner, currentLikeState in
                likeButtonStatusRelay.accept(!currentLikeState)
                Task {
                    do {
                        let newLikeStatus = try await owner.togglePerformanceLikeUseCase.execute(performanceID: owner.performanceID)
                        likeButtonStatusRelay.accept(newLikeStatus)
                    } catch {
                        likeButtonStatusRelay.accept(currentLikeState)
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
        
        // TODO: 기록 유무 여부에 따라 저장 버튼 상태 분기처리하기 (Remote 데이터 처리는 어떻게 할 것인지...)
        input.addRecordButtonTapped
            .withLatestFrom(performanceDetail)
            .bind(to: showAddRecordVCRelay)
            .disposed(by: disposeBag)
        
        return .init(
            posterURL: Observable<String>.just(posterURL),
            performanceDetail: performanceDetail.asObservable(),
            showFacilityDetail: showFacilityDetail.asObservable(),
            likeButtonSelectionState: likeButtonStatusRelay.asObservable(),
            showAddRecordVC: showAddRecordVCRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
    
}
