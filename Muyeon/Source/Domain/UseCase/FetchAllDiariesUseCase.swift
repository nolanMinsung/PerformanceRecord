//
//  FetchAllDiariesUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

protocol FetchAllDiariesUseCase {
    func execute() async throws -> [Diary]
}


final class DefaultFetchAllDiariesUseCase: FetchAllDiariesUseCase {
    
    let diaryRepository: any DiaryRepository
    
    init(diaryRepository: any DiaryRepository) {
        self.diaryRepository = diaryRepository
    }
    
    func execute() async throws -> [Diary] {
        try await diaryRepository.fetchAllDiaries()
    }
}
