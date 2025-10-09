//
//  FacilityListRequestParameter.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation
import Alamofire

struct FacilityListRequestParameter: ParameterConvertible {
    /// 발급받은 인증키
    let service: String
    /// 현재페이지
    let cpage: Int
    /// 페이지당 목록 수
    let rows: Int
    /// 공연시설명
    let shprfnmfct: String?
    /// 공연시설특성코드
    let fcltychartr: Int?
    /// 지역(시도)코드
    let signgucode: Int?
    /// 지역(구군)코드
    let signgucodesub: Int?
    /// 해당일자 이후 등록/수정된 항목만 출력
    let afterdate: Date?
    
    init(
        service: String,
        cpage: Int,
        rows: Int,
        shprfnmfct: String? = nil,
        fcltychartr: Int? = nil,
        signgucode: Int? = nil,
        signgucodesub: Int? = nil,
        afterdate: Date? = nil,
    ) {
        self.service = service
        self.cpage = cpage
        self.rows = rows.clipped(lowerBound: 0, upperBound: 100)
        self.shprfnmfct = shprfnmfct
        self.fcltychartr = fcltychartr
        self.signgucode = signgucode
        self.signgucodesub = signgucodesub
        self.afterdate = afterdate
    }
}

