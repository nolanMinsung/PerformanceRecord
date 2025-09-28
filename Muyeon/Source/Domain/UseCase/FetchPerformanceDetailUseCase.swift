//
//  FetchPerformanceDetailUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchPerformanceDetailUseCase {
    func execute(performanceID: String) async throws -> PerformanceDetailListResponse
}


final class DefaultFetchPerformanceDetailUseCase: FetchPerformanceDetailUseCase {
    func execute(performanceID: String) async throws -> PerformanceDetailListResponse {
        return try await NetworkManager.requestValue(
            router: .getPerformanceDetail(apiKey: InfoPlist.apiKey, performanceID: performanceID),
            decodingType: PerformanceDetailListResponse.self
        )
    }
}
