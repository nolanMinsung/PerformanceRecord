//
//  Router.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation
import Alamofire


enum KOPISRouter {
    case getPerformanceList(param: PerformanceListRequestParameter)
    case getPerformanceDetail(apiKey: String, performanceID: String)
    case getFacilityList(param: FacilityListRequestParameter)
    case getFacilityDetail(apiKey: String, facilityID: String)
    case getBoxOffice(param: BoxOfficeRequestParameter)
}

extension KOPISRouter {
    
    var baseURL: String { "https://www.kopis.or.kr/openApi/restful" }
    var path: String {
        switch self {
        case .getPerformanceList:
            return "/pblprfr"
        case .getPerformanceDetail(_, let performanceID):
            return "/pblprfr/\(performanceID)"
        case .getFacilityList:
            return "/prfplc"
        case .getFacilityDetail(_, let facilityID):
            return "/prfplc/\(facilityID)"
        case .getBoxOffice:
            return "/boxoffice"
        }
    }
    var endPoint: String {
        return baseURL + path
    }
    
    var method: HTTPMethod {
        switch self {
        case .getPerformanceList, .getPerformanceDetail, .getFacilityList, .getFacilityDetail, .getBoxOffice:
            return .get
        }
    }
    
    var queryParameters: Parameters? {
        get throws {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            switch self {
            case .getPerformanceList(let param):
                return try param.asParameters(dateEncodingStrategy: .formatted(formatter))
            case .getPerformanceDetail(let apiKey, _):
                return ["service": apiKey]
            case .getFacilityList(let param):
                return try param.asParameters(dateEncodingStrategy: .formatted(formatter))
            case .getFacilityDetail(let apiKey, _):
                return ["service": apiKey]
            case .getBoxOffice(let param):
                return try param.asParameters(dateEncodingStrategy: .formatted(formatter))
            }
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getPerformanceList, .getPerformanceDetail, .getFacilityList, .getFacilityDetail, .getBoxOffice:
            return nil
        }
    }
    
}
