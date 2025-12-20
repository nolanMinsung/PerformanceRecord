//
//  MockTogglePerformanceLikeUseCase.swift
//  PerformanceRecord
//
//  Created by 김민성 on 12/20/25.
//

import Foundation
import RxSwift
import RxCocoa

@testable import PerformanceRecord
final class MockTogglePerformanceLikeUseCase: TogglePerformanceLikeUseCase {
    var result: Bool = true
    
    func execute(performanceID: String) async throws -> Bool {
        return result
    }
}
