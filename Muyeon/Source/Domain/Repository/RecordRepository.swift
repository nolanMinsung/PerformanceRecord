//
//  RecordRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

protocol RecordRepository {
    func createDiary(_ diary: Record, images imageData: [ImageDataForSaving]) async throws
    func fetchDiaries(of performance: Performance) async throws -> [Record]
    func fetchAllDiaries() async throws -> [Record]
    func deleteRecord(_ record: Record) async throws
}
