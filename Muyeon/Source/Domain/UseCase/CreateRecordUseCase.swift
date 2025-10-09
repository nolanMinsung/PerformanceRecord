//
//  CreateRecordUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

protocol CreateRecordUseCase {
    func execute(record: Record, imageData: [ImageDataForSaving]) async throws
}


final class DefaultCreateRecordUseCase: CreateRecordUseCase {
    
    // TODO: Diary -> Record로 이름 변경
    // TODO: Record 생성 전에, Performance 정보가 로컬에 저장되었는지 확인
    private let performanceRepository: any PerformanceRepository
    private let recordRepository: any RecordRepository
    
    init(
        performanceRepository: any PerformanceRepository,
        recordRepository: any RecordRepository
    ) {
        self.performanceRepository = performanceRepository
        self.recordRepository = recordRepository
    }
    
    func execute(record: Record, imageData: [ImageDataForSaving]) async throws {
        let performanceID = record.performanceID
        let remotePerformanceDetail = try await performanceRepository.fetchDetailFromRemote(id: performanceID)
        do {
            let _ = try await performanceRepository.fetchDetailFromLocal(id: performanceID)
            try await recordRepository.createDiary(record, images: imageData)
        } catch {
            if case .performanceObjectNotFound = (error as? DefaultPerformanceRepositoryError) {
                // 로컬에 Performance 데이터가 없어서 에러를 던지는 경우에는 로컬에 데이터를 저장한 후 Record 저장
                try await performanceRepository.save(performance: remotePerformanceDetail)
                try await recordRepository.createDiary(record, images: imageData)
            } else {
                throw error
            }
        }
    }
}


