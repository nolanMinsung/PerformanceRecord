//
//  FetchLocalPerformanceListUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

protocol FetchLocalPerformanceListUseCase {
    func execute() async throws -> [Performance]
}


final class DefaultFetchLocalPerformanceListUseCase: FetchLocalPerformanceListUseCase {
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: any PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute() async throws -> [Performance] {
        try await performanceRepository.fetchAllPerformanceListFromLocal()
    }
}
