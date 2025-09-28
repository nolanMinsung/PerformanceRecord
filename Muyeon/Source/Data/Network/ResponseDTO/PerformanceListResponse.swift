//
//  PerformanceListResponse.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/25/25.
//

import Foundation
import XMLCoder

/**
 * 최상위 `<dbs>` XML 요소를 나타내는 구조체
 * 이 구조체는 내부에 `db`라는 이름의 `Performance` 객체 배열을 가짐
 */
struct PerformanceListResponse: Codable {
    /// XML의 `<db>` 요소 배열에 해당
    let db: [PerformanceResponse]
}

/**
 * `<db>` XML 요소를 나타내는 구조체.
 * 공연 하나에 대한 상세 정보를 담고 있음.
 */
struct PerformanceResponse: Codable, Hashable {
    /// 공연 ID
    let mt20id: String
    
    /// 공연명
    let prfnm: String
    
    /// 공연 시작일
    let prfpdfrom: String
    
    /// 공연 종료일
    let prfpdto: String
    
    /// 공연 시설명
    let fcltynm: String
    
    /// 포스터 이미지 URL
    let poster: String
    
    /// 공연 지역
    let area: String
    
    /// 공연 장르명
    let genrenm: String
    
    /// 오픈런 여부
    let openrun: String
    
    /// 공연 상태
    let prfstate: String
}
