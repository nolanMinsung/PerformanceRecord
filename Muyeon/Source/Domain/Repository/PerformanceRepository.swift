//
//  PerformanceRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

protocol PerformanceRepository {
    func fetchDetailFromRemote(id: String) async throws -> Performance
    func fetchDetailFromLocal(id: String) async throws -> Performance
    func fetchLikeFromLocal() async throws -> [Performance]
    func save(performance: Performance) async throws
    func delete(performance: Performance) async throws
}
