//
//  FetchAllRecordsUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

protocol FetchAllRecordsUseCase {
    func execute() async throws -> [Record]
}


final class DefaultFetchAllRecordsUseCase: FetchAllRecordsUseCase {
    
    private let recordRepository: any RecordRepository
    
    init(recordRepository: any RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute() async throws -> [Record] {
        try await recordRepository.fetchAllRecords()
    }
}
