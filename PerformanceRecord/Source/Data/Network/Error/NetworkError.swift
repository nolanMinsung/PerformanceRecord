//
//  NetworkError.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import Foundation

/// 프로젝트 내에서 사용될 네트워크 통신 에러.
///
/// 뷰/뷰모델에서 AFError 등에 대한 의존도를 낮추고 다양한 에러를 추상화하기 위함.
///
/// 필요에 따라 케이스들이 추가 및 삭제될 수 있음.
enum NetworkError: LocalizedError {
    
    // 정의는 했으나, 아직 사용되지는 않음.
    enum ConnectionError {
        case timeout
        case notConnectedToInternet
        case networkCancelled
        case unknown
    }
    
    case invalidStatusCode(code: Int, message: String?)
    case decodingError(any Error)
    case connectionError(ConnectionError)
    case dataFileNil
    case unknwon(any Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidStatusCode(let code, let message):
            return "200번대가 아닌 상태 코드입니다. 상태 코드: \(code), 메시지: \(message ?? "")"
        case .decodingError:
            return "디코딩에 실패했습니다."
        case .connectionError(let error):
            return "네트워크 통신 에러. reason: \(error)"
        case .dataFileNil:
            return "서버 응답값의 data가 존재하지 않습니다."
        case .unknwon:
            return "기타 알 수 없는 오류입니다."
        }
    }
    
    var displayMessage: String {
        switch self {
        case .invalidStatusCode(_, let message):
            return message ?? "문제가 발생했습니다. 잠시 후 다시 시도해 주세요"
        case .connectionError(let connectionError):
            // connectionError의 case별로 분기처리하여 메시지를 세분화할 수도 있을 것...
            // 예) .notConnectedToInternet에서는 "인터넷에 연결되어있지 않습니다." 등..
            return "네트워크 연결이 일시적으로 원활하지 않습니다. 데이터 또는 Wi-Fi 연결 상태를 확인해 주세요."
        case .dataFileNil:
            return "서버로부터 응답값을 받아오지 못했습니다. 잠시 후 다시 시도해 주세요."
        default:
            return "문제가 발생했습니다. 잠시 후 다시 시도해 주세요"
        }
    }
    
}
