//
//  Performance.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

struct Performance: Identifiable, Hashable {
    let id: String // mt20id(공연ID)
    let name: String // prfnm(공연명)
    let startDate: Date // prfpdfrom(공연시작일)
    let endDate: Date // prfpdto(공연종료일)
    let facilityFullName: String // fcltynm(공연시설명(공연장명))
    var facilityName: String { "" } // TODO: facilityFullName에서 정보 파싱 구현
    var venueName: String { "" } // TODO: facilityFullName에서 정보 파싱 구현
    let posterURL: String // poster(포스터이미지경로)
    let area: Constant.AdminAreaCode // area(공연지역)
    let genre: Constant.Genre // genrenm(공연)
    let openRun: Bool // openrun(오픈런)
    let state: Constant.PerformanceState // prfstate(공연상태)
    
    let detail: PerformanceDetail?
}

struct PerformanceDetail: Hashable {
    let cast: String // prfcast (출연진)
    let crew: String // prfcrew (제작진)
    let runtime: String // prfruntime
    let ageLimit: String // prfage (관람 연령)
    let enterpriseName: String // entrpsnm(기획제작사)
    let enterpriseNameP: String // entrpsnmP(제작사)
    let enterpriseNameA: String // entrpsnmA(기획사)
    let enterpriseNameH: String // entrpsnmH(주최)
    let enterpriseNameS: String // entrpsnmS(주관)
    let priceGuidance: String // pcseguidance (가격 정보)
    let story: Bool // sty (줄거리)
    let visitingKorea: Bool // visit(내한)    N
    let child: Bool // child(아동)    N
    let daehakro: Bool // daehakro(대학로)    Y
    let isFestival: Bool // festival(축제 )   N
    let musicalLicense: Bool // musicallicense(뮤지컬 라이센스)    N
    let musicalCreate: Bool // musicalcreate(뮤지컬 창작)    N
    let updateDate: Date // updatedate(최종수정일)    2019-07-25 10:03:14
    let facilityID: String // mt10id는 Facility의 ID이므로 여기에 두는 것이 적절
    let detailDateGuidance: String // dtguidance (상세 일정)
    let detailImageURLs: [String] // styurls (소개 이미지)
    let relatedLinks: [RelatedLink] // relates (예매처 목록)
}

struct RelatedLink: Identifiable, Hashable {
    let id = UUID()
    let name: String // relatenm
    let url: String // relateurl
}
