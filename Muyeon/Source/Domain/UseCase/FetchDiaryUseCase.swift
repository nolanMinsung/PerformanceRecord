//
//  FetchRecordsUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import Foundation

protocol FetchRecordsUseCase {
    func execute(performance: Performance) async throws -> [Record]
}


final class DefaultFetchRecordsUseCase: FetchRecordsUseCase {
    
    private let recordRepository: any RecordRepository
    
    init(recordRepository: any RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute(performance: Performance) async throws -> [Record] {
        try await recordRepository.fetchRecords(of: performance)
    }
    
}
