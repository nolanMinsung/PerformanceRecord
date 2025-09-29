//
//  NetworkManager.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

import Alamofire
import RxSwift
import XMLCoder


struct XMLResponseSerializer<T: Decodable>: DataResponseSerializerProtocol {
    
    typealias SerializedObject = T
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: (any Error)?) throws -> T {
        guard let data, !data.isEmpty else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        
        do {
            let xmlDeCoder = XMLDecoder()
            let model = try xmlDeCoder.decode(T.self, from: data)
            return model
        } catch {
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: error))
        }
    }
    
}


final class NetworkManager {
    
    static func requestValue<T: Decodable>(router: KOPISRouter, decodingType: T.Type) async throws -> T {
        let serializer = XMLResponseSerializer<T>()
        let request = AF.request(
            router.endPoint,
            method: router.method,
            parameters: try router.queryParameters,
            headers: router.headers,
        )
        
        do {
            let value = try await request.serializingResponse(using: serializer).value
            return value
        } catch {
            throw error
        }
    }
    
    static func requestString(router: KOPISRouter) async throws -> String {
        let request = AF.request(
            router.endPoint,
            method: router.method,
            parameters: try router.queryParameters,
            encoding: URLEncoding.queryString,
            headers: router.headers,
        )
        do {
            // utf8로 인코딩 필수!
            let value = try await request.serializingString(encoding: .utf8).value
            return value
        } catch {
            throw error
        }
    }
    
}
