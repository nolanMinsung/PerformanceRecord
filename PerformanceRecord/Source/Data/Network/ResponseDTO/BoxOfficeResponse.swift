//
//  BoxOfficeResponse.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
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
    /// 장르 ex) 연극
    let cate: String
    
    /// 순위 ex) 8
    let rnum: Int
    
    /// 공연명 ex) 온 더 비트
    let prfnm: String
    
    /// 공연 기간 ex) 2023.05.17~2023.06.25
    let prfpd: String
    
    /// 상연 횟수 ex) 0
    let prfdtcnt: Int?
    
    /// 지역 ex) 서울
    let area: String
    
    /// 공연장명 ex) 티오엠씨어터(구. 문화공간필링) 2관
    let prfplcnm: String
    
    /// 좌석 수 ex) 220
    let seatcnt: Int?
    
    /// 포스터 URL ex) http://www.kopis.or.kr/upload/pfmPoster/PF_PF217129_230420_112243.gif
    let poster: String
    
    /// 공연 ID ex) PF217129
    let mt20id: String
}


extension BoxOfficeResponse {
    
    func toDomain() -> [BoxOfficeItem] {
        return boxof.map {
            return BoxOfficeItem(
                id: $0.mt20id,
                category: Constant.BoxOfficeGenre.findBy(name: $0.cate),
                rank: $0.rnum,
                name: $0.prfnm,
                performPeriod: $0.prfpd,
                performingCount: $0.prfdtcnt ?? 0,
                area: Constant.BoxOfficeArea.findBy(name: $0.area),
                seatCount: $0.seatcnt ?? 0,
                performingPlaceName: $0.prfplcnm,
                posterURL: $0.poster.convertURLToHTTPS()
            )
        }
    }
    
}
