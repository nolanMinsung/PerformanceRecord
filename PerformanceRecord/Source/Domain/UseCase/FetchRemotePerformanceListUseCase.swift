//
//  FetchRemotePerformanceListUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchRemotePerformanceListUseCase {
    func execute(requestInfo: PerformanceListRequestParameter) async throws -> [Performance]
}


final class DefaultFetchRemotePerformanceListUseCase: FetchRemotePerformanceListUseCase {
    func execute(requestInfo parameter: PerformanceListRequestParameter) async throws -> [Performance] {
        let performanceListResponse = try await NetworkManager.requestValue(
            router: .getPerformanceList(param: parameter),
            decodingType: PerformanceListResponse.self
        )
        return performanceListResponse.toDomain()
    }
}
