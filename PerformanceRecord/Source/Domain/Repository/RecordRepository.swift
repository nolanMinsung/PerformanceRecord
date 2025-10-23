//
//  RecordRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

protocol RecordRepository {
    func createRecord(_ record: Record, images imageData: [ImageDataForSaving]) async throws
    func fetchRecords(of performance: Performance) async throws -> [Record]
    func fetchAllRecords() async throws -> [Record]
    func updateRecord(id: String, viewedDate: Date?, rating: Double?, reviewText: String?) async throws
    func deleteRecord(_ record: Record) async throws
}
