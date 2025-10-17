//
//  TogglePerformanceLikeUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

protocol TogglePerformanceLikeUseCase {
    func execute(performanceID: String) async throws -> Bool
}


final class DefaultTogglePerformanceLikeUseCase: TogglePerformanceLikeUseCase {
    
    @UserDefault(key: .likePerformanceIDs, defaultValue: [])
    private var likePerformanceList: [String]
    
    private let performanceRepository: any PerformanceRepository
    
    init(performanceRepository: any PerformanceRepository) {
        self.performanceRepository = performanceRepository
    }
    
    func execute(performanceID: String) async throws -> Bool {
        var newList = likePerformanceList
        if likePerformanceList.contains(performanceID) {
            let performance = try await performanceRepository.fetchDetailFromLocal(id: performanceID)
            if performance.records.isEmpty {
                // 기록이 없다면 Performance 데이터 삭제해도 된다.
                debugPrint("좋아요 해제한 공연에 기록이 없으므로 로컬 저장소에서 Performance를 삭제합니다.")
                try await performanceRepository.delete(performanceID: performanceID)
            }
            newList.removeAll { $0 == performanceID }
            likePerformanceList = newList
            return false
        } else {
            let localPerformance = try? await performanceRepository.fetchDetailFromLocal(id: performanceID)
            if localPerformance == nil {
                let downloadedPerformance = try await performanceRepository.fetchDetailFromRemote(id: performanceID)
                try await performanceRepository.save(performance: downloadedPerformance)
            }
            newList.append(performanceID)
            likePerformanceList = newList
            return true
        }
    }
}
