//
//  BoxOfficeResponse.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/25/25.
//

import Foundation
import XMLCoder

/**
 * 최상위 `<boxofs>` XML 요소를 나타내는 구조체
 */
struct BoxOfficeResponse: Codable {
    /// XML의 `<boxof>` 요소 배열에 해당
    let boxof: [BoxOfficeItemResponse]
}

/**
 * `<boxof>` XML 요소를 나타내는 구조체
 * 박스오피스 순위권에 있는 공연 하나의 정보를 담음.
 */
struct BoxOfficeItemResponse: Codable, Hashable {
    /// 장르
    let cate: String
    
    /// 순위
    let rnum: String
    
    /// 공연명
    let prfnm: String
    
    /// 공연 기간
    let prfpd: String
    
    /// 공연 횟수
    let prfdtcnt: String?
    
    /// 지역
    let area: String
    
    /// 공연장명
    let prfplcnm: String
    
    /// 좌석 수
    let seatcnt: String?
    
    /// 포스터 URL
    let poster: String
    
    /// 공연 ID
    let mt20id: String
}
