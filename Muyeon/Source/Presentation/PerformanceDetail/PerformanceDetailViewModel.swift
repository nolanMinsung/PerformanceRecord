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
        let facilityButtonTapped: Observable<String>
    }
    
    struct Output {
        let performanceDetail: Observable<Performance>
        let showFacilityDetail: Observable<String>
    }
    
    let performanceID: String
    let fetchPerformanceDetailUseCase: any FetchPerformanceDetailUseCase
    private let disposeBag = DisposeBag()
    
    init(performanceID: String, fetchPerformanceDetailUseCase: some FetchPerformanceDetailUseCase) {
        self.performanceID = performanceID
        self.fetchPerformanceDetailUseCase = fetchPerformanceDetailUseCase
    }
    
    func transform(input: Input) -> Output {
        let performanceDetail = PublishRelay<Performance>()
        let showFacilityDetail = PublishRelay<String>()
        
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
            performanceDetail: performanceDetail.asObservable(),
            showFacilityDetail: showFacilityDetail.asObservable()
        )
    }
    
}
