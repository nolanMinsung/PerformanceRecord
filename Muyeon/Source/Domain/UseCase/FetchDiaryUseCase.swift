//
//  FetchDiaryUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import Foundation

protocol FetchDiariesUseCase {
    func execute(performance: Performance) async throws -> [Record]
}


final class DefaultFetchDiariesUseCase: FetchDiariesUseCase {
    
    let diaryRepository: any DiaryRepository
    
    init(diaryRepository: any DiaryRepository) {
        self.diaryRepository = diaryRepository
    }
    
    func execute(performance: Performance) async throws -> [Record] {
        try await diaryRepository.fetchDiaries(of: performance)
    }
    
}
