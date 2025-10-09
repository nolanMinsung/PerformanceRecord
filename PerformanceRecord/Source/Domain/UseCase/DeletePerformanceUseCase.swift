//
//  DeletePerformanceUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

protocol DeletePerformanceUseCase {
    func execute(performanceID: String) async throws
}


final class DefaultDeletePerformanceUseCase: DeletePerformanceUseCase {
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute(performanceID: String) async throws {
        try await performanceRepository.delete(performanceID: performanceID)
    }
    
}
