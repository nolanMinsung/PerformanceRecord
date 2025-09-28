//
//  Facility.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

struct Facility: Identifiable {
    // 필수 공통 정보 (시설 목록 조회 응답값 기준)
    let id: String           // mt10id
    let name: String         // fcltynm
    let performanceCount: Int // mt13cnt (공연장 개수)
    let character: Constant.FacilityCharacteristic    // fcltychartr (시설 특성)
    let sidoName: Constant.AdminAreaCode?    // sidonm (시도명) - 해외인 경우 nil
    let gugunName: Constant.AdminDistrictCode?   // gugunnm (구군명) - 해외인 경우 nil
    let openYear: Int?       // opende (개관연도, String을 Int로 변환) - 해외인 경우 nil
    
    // 상세 정보는 옵셔널 속성으로 포함
    let detail: FacilityDetail?
}


struct FacilityDetail {
    // 시설 상세 정보 (시설 상세 조회 응답값 기준)
    let totalSeatScale: Int? // seatscale (총 좌석수) - 해외인 경우 0
    let telNumber: String?   // telno (전화번호) - 해외인 경우 nil
    let relatedURL: URL?     // relateurl
    let address: String?     // adres (주소) - 해외인 경우 nil
    
    // 위치 정보
    let latitude: Double?    // la (위도, String을 Double로 변환) - 해외인 경우 nil
    let longitude: Double?   // lo (경도, String을 Double로 변환) - 해외인 경우 nil
    
    // 편의 시설 정보 (XML의 Y/N 값을 Bool로 변환)
    let hasRestaurant: Bool  // restaurant
    let hasCafe: Bool        // cafe
    let hasStore: Bool       // store
    let hasNolibang: Bool    // nolibang (놀이방)
    let hasSuyusil: Bool     // suyu (수유실)
    
    // 장애인 편의시설 정보 (예: parkbarrier, restbarrier 등)
    let hasParkingBarrier: Bool // parkbarrier
    let hasRestroomBarrier: Bool // restbarrier
    let hasRunwayBarrier: Bool // runwbarrier
    let hasElevatorBarrier: Bool // elevbarrier
    let hasParkingLot: Bool  // parkinglot
    
    // 상세 공연장 목록
    let subVenues: [SubVenue] // mt13s 하위 목록
}


struct SubVenue: Identifiable {
    let id: String           // mt13id
    let name: String         // prfplcnm (공연장 이름)
    let seatScale: Int      // seatscale (좌석 수, String을 Int로 변환)
    
    // 기타 상세 정보 필드 (예: stageorchat, stagepracat 등)
    let hasOrchestraPit: Bool      // stageorchat
    let hasPracticeRoom: Bool      // stagepracat
    let hasDressingRoom: Bool      // stagedresat
    let hasOutdoorStage: Bool      // stageoutdrat
    let disabledSeatScale: Int    // disabledseatscale (장애인 좌석 수)
    let stageArea: String         // stagearea (무대 면적)
}
