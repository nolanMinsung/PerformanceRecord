//
//  SavePerformanceUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

protocol SavePerformanceUseCase {
    func execute(performance: Performance) async throws
}


final class DefaultSavePerformanceUseCase: SavePerformanceUseCase {
    
    private let repository: PerformanceRepository
    
    init(repository: any PerformanceRepository) {
        self.repository = repository
    }
    
    func execute(performance: Performance) async throws {
        try await repository.save(performance: performance)
    }
    
}
