//
//  FetchLocalPerformanceDetailUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

protocol FetchLocalPerformanceDetailUseCase {
    func execute(performanceID: String) async throws -> Performance
}


final class DefaultFetchLocalPerformanceDetailUseCase: FetchLocalPerformanceDetailUseCase {
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: any PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute(performanceID: String) async throws -> Performance {
        return try await performanceRepository.fetchDetailFromLocal(id: performanceID)
    }
}
