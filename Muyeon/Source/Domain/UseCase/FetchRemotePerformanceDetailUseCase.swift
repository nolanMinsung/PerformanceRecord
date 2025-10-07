//
//  FetchRemotePerformanceDetailUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchRemotePerformanceDetailUseCase {
    func execute(performanceID: String) async throws -> Performance
}


final class DefaultFetchRemotePerformanceDetailUseCase: FetchRemotePerformanceDetailUseCase {
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: any PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute(performanceID: String) async throws -> Performance {
        return try await performanceRepository.fetchDetailFromRemote(id: performanceID)
    }
}
