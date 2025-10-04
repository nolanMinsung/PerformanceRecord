//
//  TogglePerformanceLikeUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

protocol TogglePerformanceLikeUseCase {
    func execute(performanceID: String) throws
}


final class DefaultTogglePerformanceLikeUseCase: TogglePerformanceLikeUseCase {
    
    @UserDefault(key: .likePerformanceIDs, defaultValue: [])
    private var likePerformanceList: [String]
    
    func execute(performanceID: String) throws {
        var newList = likePerformanceList
        if likePerformanceList.contains(performanceID) {
            newList.removeAll { $0 == performanceID }
        } else {
            newList.append(performanceID)
        }
        likePerformanceList = newList
    }
}
