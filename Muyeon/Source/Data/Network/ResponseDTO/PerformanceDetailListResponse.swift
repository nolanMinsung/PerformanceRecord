//
//  PerformanceDetailListResponse.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/25/25.
//

import Foundation
import XMLCoder

/**
 * 최상위 `<dbs>` XML 요소를 나타내는 구조체
 */
struct PerformanceDetailListResponse: Codable {
    /// XML의 `<db>` 요소에 해당. 상세 정보는 배열이 아닌 단일 객체일 수 있으나,
    /// XML 구조상 복수형(`dbs`)으로 되어 있어 배열로 처리하는 것이 안전.
    let db: [PerformanceDetailResponse]
}

/**
 * `<db>` XML 요소를 나타내는 구조체로, 공연의 상세 정보를 담음.
 */
struct PerformanceDetailResponse: Codable, Hashable {
    let mt20id: String
    let prfnm: String
    let prfpdfrom: String
    let prfpdto: String
    let fcltynm: String
    let prfcast: String
    let prfcrew: String
    let prfruntime: String
    let prfage: String
    let entrpsnm: String
    let entrpsnmP: String?
    let entrpsnmA: String?
    let entrpsnmH: String?
    let entrpsnmS: String?
    let pcseguidance: String
    let poster: String
    let sty: String?
    let area: String
    let genrenm: String
    let openrun: String
    let visit: String?
    let child: String?
    let daehakro: String?
    let festival: String?
    let musicallicense: String?
    let musicalcreate: String?
    let updatedate: String?
    let prfstate: String
    let mt10id: String
    let dtguidance: String
    
    /// `<styurls>` 태그에 해당하는 중첩된 이미지 URL 목록
    let styurls: StyURLsResponse
    
    /// `<relates>` 태그에 해당하는 중첩된 관련 정보 목록
    let relates: RelatesResponse
}

/**
 * `<styurls>` XML 요소를 나타내는 구조체
 * 내부에 여러 개의 `<styurl>` 문자열을 배열로 가짐.
 */
struct StyURLsResponse: Codable, Hashable {
    /// 상세 이미지 URL 배열
    let styurl: [String]
}

/**
 * `<relates>` XML 요소를 나타내는 구조체
 * 내부에 여러 개의 `<relate>` 객체를 배열로 가짐.
 */
struct RelatesResponse: Codable, Hashable {
    let relate: [RelateResponse]
}

/**
 * `<relate>` XML 요소를 나타내는 구조체.
 * 관련 사이트 이름과 URL 정보를 담음
 */
struct RelateResponse: Codable, Hashable {
    /// 관련 사이트명 (예: NHN티켓링크)
    let relatenm: String
    /// 관련 사이트 URL
    let relateurl: String
}
