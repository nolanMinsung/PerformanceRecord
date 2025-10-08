//
//  DeleteRecordUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/8/25.
//

protocol DeleteRecordUseCase {
    func execute(record: Record) async throws
}


final class DefaultDeleteRecordUseCase: DeleteRecordUseCase {
    
    let recordRepository: any RecordRepository
    
    init(recordRepository: any RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute(record: Record) async throws {
        try await recordRepository.deleteRecord(record)
    }
    
}
