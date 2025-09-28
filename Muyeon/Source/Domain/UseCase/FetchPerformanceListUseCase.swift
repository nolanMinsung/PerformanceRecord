//
//  FetchPerformanceListUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchPerformanceListUseCase {
    func execute(requestInfo: PerformanceListRequestParameter) async throws -> PerformanceListResponse
}


final class DefaultFetchPerformanceListUseCase: FetchPerformanceListUseCase {
    func execute(requestInfo parameter: PerformanceListRequestParameter) async throws -> PerformanceListResponse {
        return try await NetworkManager.requestValue(
            router: .getPerformanceList(param: parameter),
            decodingType: PerformanceListResponse.self
        )
    }
}
