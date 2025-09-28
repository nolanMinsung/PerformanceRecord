//
//  FacilityListResponse.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/25/25.
//

import Foundation
import XMLCoder

/**
 * 최상위 `<dbs>` XML 요소를 나타내는 구조체
 * 내부에 'db'라는 이름의 `Facility` 객체 배열을 포함함.
 */
struct FacilityListResponse: Codable {
    /// XML의 `<db>` 요소 배열에 해당.
    let db: [FacilityResponse]
}

/**
 * `<db>` XML 요소를 나타내는 구조체
 * 공연 시설 하나의 정보를 담음.
 * XML의 빈 태그(<opende></opende>)는 디코딩 시 빈 문자열("")로 처리됨.
 */
struct FacilityResponse: Codable, Hashable {
    /// 시설명
    let fcltynm: String
    
    /// 공연시설 ID
    let mt10id: String
    
    /// 공연장 수
    let mt13cnt: String
    
    /// 시설 특성
    let fcltychartr: String
    
    /// 시도명
    let sidonm: String
    
    /// 구군명
    let gugunnm: String
    
    /// 개관연도
    let opende: String
}
