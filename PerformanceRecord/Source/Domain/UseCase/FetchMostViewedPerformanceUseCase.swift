//
//  FetchMostViewedPerformanceUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

protocol FetchMostViewedPerformanceUseCase {
    func execute() async throws -> Performance?
}


final class DefaultFetchMostViewedPerformanceUseCase: FetchMostViewedPerformanceUseCase {
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: any PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute() async throws -> Performance? {
        try await performanceRepository.fetchMostViewedFromLocal()
    }
    
}
