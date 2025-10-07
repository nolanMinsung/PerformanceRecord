//
//  FetchAllDiariesUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

protocol FetchAllDiariesUseCase {
    func execute() async throws -> [Record]
}


final class DefaultFetchAllDiariesUseCase: FetchAllDiariesUseCase {
    
    let diaryRepository: any DiaryRepository
    
    init(diaryRepository: any DiaryRepository) {
        self.diaryRepository = diaryRepository
    }
    
    func execute() async throws -> [Record] {
        try await diaryRepository.fetchAllDiaries()
    }
}
