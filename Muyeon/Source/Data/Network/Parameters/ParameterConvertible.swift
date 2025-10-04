//
//  ParameterConvertible.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation
import Alamofire

enum DateEncodingStrategy {
    case formatted(DateFormatter)
    case iso8601
    case custom((Date) -> String)
}

protocol ParameterConvertible: Encodable {
    func asParameters(dateEncodingStrategy: DateEncodingStrategy) throws -> [String: Any]
}

extension ParameterConvertible {
    func asParameters(dateEncodingStrategy: DateEncodingStrategy = .iso8601) throws -> [String: Any] {
        let encoder = JSONEncoder()
        
        switch dateEncodingStrategy {
        case .formatted(let formatter):
            encoder.dateEncodingStrategy = .formatted(formatter)
        case .iso8601:
            encoder.dateEncodingStrategy = .iso8601
        case .custom(let transform):
            encoder.dateEncodingStrategy = .custom { date, encoder in
                var container = encoder.singleValueContainer()
                try container.encode(transform(date))
            }
        }

        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard var dict = object as? [String: Any] else {
            throw NSError(domain: "ParameterEncodingError", code: -1, userInfo: nil)
        }

        // nil 제거 (Encodable에서는 nil이 빠지긴 하지만 안전하게 처리)
        dict = dict.filter { !($0.value is NSNull) }
        return dict
    }
}
