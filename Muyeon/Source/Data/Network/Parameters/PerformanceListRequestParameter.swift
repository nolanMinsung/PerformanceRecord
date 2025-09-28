//
//  PerformanceListRequestParameter.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation
import Alamofire

struct PerformanceListRequestParameter: ParameterConvertible {
    let service = InfoPlist.apiKey
    let stdate: Date
    let eddate: Date
    let cpage: Int
    var rows: Int
    
    let shprfnm: String?
    let shprfnmfct: String?
    let shcate: String?
    let prfplccd: String?
    let signgucode: String?
    let signgucodesub: String?
    let kidstate: String?
    let prfstate: Int?
    let openrun: String?
    let afterdate: String?
    
    init(
        stdate: Date,
        eddate: Date,
        cpage: Int,
        rows: Int,
        shprfnm: String? = nil,
        shprfnmfct: String? = nil,
        shcate: String? = nil,
        prfplccd: String? = nil,
        signgucode: String? = nil,
        signgucodesub: String? = nil,
        kidstate: String? = nil,
        prfstate: Int? = nil,
        openrun: String? = nil,
        afterdate: String? = nil,
    ) {
        self.stdate = stdate
        self.eddate = eddate
        self.cpage = cpage
        self.rows = rows.clipped(lowerBound: 0, upperBound: 100)
        self.shprfnm = shprfnm
        self.shprfnmfct = shprfnmfct
        self.shcate = shcate
        self.prfplccd = prfplccd
        self.signgucode = signgucode
        self.signgucodesub = signgucodesub
        self.kidstate = kidstate
        self.prfstate = prfstate
        self.openrun = openrun
        self.afterdate = afterdate
    }
}
