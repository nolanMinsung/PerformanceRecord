//
//  TogglePerformanceLikeUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

protocol TogglePerformanceLikeUseCase {
    func execute(performanceID: String) -> Bool
}


final class DefaultTogglePerformanceLikeUseCase: TogglePerformanceLikeUseCase {
    
    @UserDefault(key: .likePerformanceIDs, defaultValue: [])
    private var likePerformanceList: [String]
    
    func execute(performanceID: String) -> Bool {
        var newList = likePerformanceList
        if likePerformanceList.contains(performanceID) {
            newList.removeAll { $0 == performanceID }
            likePerformanceList = newList
            return false
        } else {
            newList.append(performanceID)
            likePerformanceList = newList
            return true
        }
    }
}
