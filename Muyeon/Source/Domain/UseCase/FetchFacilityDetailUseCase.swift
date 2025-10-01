//
//  FetchFacilityDetailUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchFacilityDetailUseCase {
    func execute(facilityID: String) async throws -> Facility
}


final class DefaultFetchFacilityDetailUseCase: FetchFacilityDetailUseCase {
    func execute(facilityID: String) async throws -> Facility {
        try await NetworkManager.requestValue(
            router: .getFacilityDetail(apiKey: InfoPlist.apiKey, facilityID: facilityID),
            decodingType: FacilityDetailListResponse.self
        )
        .toDomain()
    }
}
