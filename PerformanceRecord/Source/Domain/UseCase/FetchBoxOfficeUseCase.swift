//
//  FetchBoxOfficeUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

protocol FetchBoxOfficeUseCase {
    func execute(requestInfo: BoxOfficeRequestParameter) async throws -> [BoxOfficeItem]
}


final class DefaultFetchBoxOfficeUseCase: FetchBoxOfficeUseCase {
    func execute(requestInfo parameter: BoxOfficeRequestParameter) async throws -> [BoxOfficeItem] {
        try await NetworkManager.requestValue(
            router: .getBoxOffice(param: parameter),
            decodingType: BoxOfficeResponse.self
        ).toDomain()
    }
}
