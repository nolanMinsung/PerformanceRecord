//
//  DeletePerformanceUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

protocol DeletePerformanceUseCase {
    func execute(performance: Performance) async throws
}


final class DefaultDeletePerformanceUseCase: DeletePerformanceUseCase {
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute(performance: Performance) async throws {
        try await performanceRepository.delete(performance: performance)
    }
    
}
