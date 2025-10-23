//
//  UpdateRecordUseCase.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/23/25.
//

import Foundation

protocol UpdateRecordUseCase {
    func execute(recordID: String, viewedDate: Date?, rating: Double?, reviewText: String?) async throws
}

final class DefaultUpdateRecordUseCase: UpdateRecordUseCase {
    
    private let recordRepository: any RecordRepository
    
    init(recordRepository: any RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute(
        recordID: String,
        viewedDate: Date? = nil,
        rating: Double? = nil,
        reviewText: String? = nil
    ) async throws {
        try await recordRepository.updateRecord(
            id: recordID,
            viewedDate: viewedDate,
            rating: rating,
            reviewText: reviewText
        )
    }
    
}
