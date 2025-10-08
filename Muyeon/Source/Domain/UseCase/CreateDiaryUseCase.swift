//
//  CreateDiaryUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

protocol CreateDiaryUseCase {
    func execute(diary: Record, imageData: [ImageDataForSaving]) async throws
}


final class DefaultCreateDiaryUseCase: CreateDiaryUseCase {
    
    let diaryRepository: any RecordRepository
    
    init(diaryRepository: any RecordRepository) {
        self.diaryRepository = diaryRepository
    }
    
    func execute(diary: Record, imageData: [ImageDataForSaving]) async throws {
        try await diaryRepository.createDiary(diary, images: imageData)
    }
}


