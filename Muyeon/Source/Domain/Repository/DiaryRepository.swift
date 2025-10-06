//
//  DiaryRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

@MainActor
protocol DiaryRepository {
    func createDiary(_ diary: Diary, images imageData: [ImageDataForSaving]) async throws
    func fetchDiaries(of performance: Performance) throws -> [Diary]
}
