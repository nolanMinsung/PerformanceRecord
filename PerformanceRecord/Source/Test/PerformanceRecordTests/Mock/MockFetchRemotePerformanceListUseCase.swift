//
//  MockFetchRemotePerformanceListUseCase.swift
//  PerformanceRecordTests
//
//  Created by 김민성 on 12/20/25.
//

import Foundation

@testable import PerformanceRecord
final class MockFetchRemotePerformanceListUseCase: FetchRemotePerformanceListUseCase {
    var result: [Performance] = []
    
    func execute(requestInfo: PerformanceListRequestParameter) async throws -> [Performance] {
        return result
    }
}
