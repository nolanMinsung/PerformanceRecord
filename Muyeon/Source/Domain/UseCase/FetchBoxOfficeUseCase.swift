//
//  FetchBoxOfficeUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchBoxOfficeUseCase {
    func execute(requestInfo: BoxOfficeRequestParameter) async throws -> BoxOfficeResponse
}


final class DefaultFetchBoxOfficeUseCase: FetchBoxOfficeUseCase {
    func execute(requestInfo parameter: BoxOfficeRequestParameter) async throws -> BoxOfficeResponse {
        try await NetworkManager.requestValue(
            router: .getBoxOffice(param: parameter),
            decodingType: BoxOfficeResponse.self
        )
    }
}
