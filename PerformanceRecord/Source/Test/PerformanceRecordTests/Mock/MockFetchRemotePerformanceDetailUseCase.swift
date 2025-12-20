//
//  MockFetchRemotePerformanceDetailUseCase.swift
//  PerformanceRecordTests
//
//  Created by 김민성 on 12/20/25.
//

import Foundation

@testable import PerformanceRecord
final class MockFetchRemotePerformanceDetailUseCase: FetchRemotePerformanceDetailUseCase {
    var result: Performance?
    
    func execute(performanceID: String) async throws -> Performance {
        if let result = result {
            return result
        }
        throw MockError.mockResultNotSet
    }
}
