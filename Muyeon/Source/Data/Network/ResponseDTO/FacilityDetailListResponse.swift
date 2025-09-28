//
//  FacilityDetailListResponse.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/25/25.
//

import Foundation
import XMLCoder

/**
 * 최상위 `<dbs>` XML 요소를 나타내는 구조체
 */
struct FacilityDetailListResponse: Codable {
    /// XML의 `<db>` 요소에 해당. 상세 정보는 배열이 아닌 단일 객체일 수 있으나,
    /// XML 구조상 복수형(`dbs`)으로 되어 있어 배열로 처리하는 것이 안전
    let db: [FacilityDetailResponse]
}

/**
 * `<db>` XML 요소를 나타내는 구조체로, 공연 시설의 상세 정보를 담음.
 */
struct FacilityDetailResponse: Codable, Hashable {
    let fcltynm: String
    let mt10id: String
    let mt13cnt: String
    let fcltychartr: String
    let opende: String
    let seatscale: String
    let telno: String?
    let relateurl: String?
    let adres: String
    let la: String
    let lo: String
    let restaurant: String?
    let cafe: String?
    let store: String?
    let nolibang: String?
    let suyu: String?
    let parkbarrier: String?
    let restbarrier: String?
    let runwbarrier: String?
    let elevbarrier: String?
    let parkinglot: String?
    
    /// `<mt13s>` 태그에 해당하는 중첩된 공연장 목록
    let mt13s: PerformancePlaceListResponse
}

/**
 * `<mt13s>` XML 요소를 나타내는 구조체
 * 내부에 여러 개의 `<mt13>` 객체를 배열로 가짐.
 */
struct PerformancePlaceListResponse: Codable, Hashable {
    let mt13: [PerformancePlaceResponse]
}

/**
 * `<mt13>` XML 요소를 나타내는 구조체
 * 개별 공연장의 상세 정보를 담음
 */
struct PerformancePlaceResponse: Codable, Hashable {
    let prfplcnm: String
    let mt13id: String
    let seatscale: String
    let stageorchat: String?
    let stagepracat: String?
    let stagedresat: String?
    let stageoutdrat: String?
    let disabledseatscale: String?
    let stagearea: String?
}
