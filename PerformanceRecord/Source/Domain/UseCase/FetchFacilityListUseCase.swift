//
//  FetchFacilityListUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchFacilityListUseCase {
    func execute(requestInfo: FacilityListRequestParameter) async throws -> FacilityListResponse
}


final class DefaultFetchFacilityListUseCase: FetchFacilityListUseCase {
    func execute(requestInfo parameter: FacilityListRequestParameter) async throws -> FacilityListResponse {
        try await NetworkManager.requestValue(
            router: .getFacilityList(param: parameter),
            decodingType: FacilityListResponse.self
        )
    }
}
