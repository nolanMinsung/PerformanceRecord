//
//  FetchLikePerformanceListUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

protocol FetchLikePerformanceListUseCase {
    func execute() async throws -> [Performance]
}


final class DefaultFetchLikePerformanceListUseCase: FetchLikePerformanceListUseCase {
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: any PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute() async throws -> [Performance] {
        try await performanceRepository.fetchLikeFromLocal()
    }
}
