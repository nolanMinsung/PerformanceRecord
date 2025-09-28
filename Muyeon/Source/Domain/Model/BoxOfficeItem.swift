//
//  BoxOfficeItem.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

struct BoxOfficeItem: Identifiable {
    let id: String // ID(mt20id)
    let category: Constant.BoxOfficeGenre // 장르
    let rank: Int // rnum (순위)
    let name: String // prfnm(공연명)
    let performPeriod: String // prfpd(공연기간)
    let performingCount: Int // prfdtcnt(상연횟수)
    let area: Constant.BoxOfficeArea // area(지역)
    let seatCount: Int // seatcnt(좌석수)
    let performingPlaceName: String // prfplcnm(공연장)
    let poster: URL? // poster(포스터이미지)
}
