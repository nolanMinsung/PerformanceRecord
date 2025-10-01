//
//  FacilityDetailListResponse.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
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
    
    
    func toDomain() throws -> Facility {
        guard let response = db.first else {
            throw FacilityDetailListResponseError.containNoContents
        }
        
        let detailInfo = FacilityDetail(
            totalSeatScale: Int(response.seatscale) ?? 0,
            telNumber: response.telno.isEmpty ? nil : response.telno,
            relatedURL: response.relateurl.isEmpty ? nil : response.relateurl,
            address: response.adres.isEmpty ? nil : response.adres,
            latitude: (response.la == "0") ? nil : (Double(response.la) ?? nil),
            longitude: (response.lo == "0") ? nil : (Double(response.lo) ?? nil),
            hasRestaurant: (response.restaurant == "Y"),
            hasCafe: (response.cafe == "Y"),
            hasStore: (response.store == "Y"),
            hasNolibang: (response.nolibang == "Y"),
            hasSuyusil: (response.suyu == "Y"),
            hasParkingBarrier: (response.parkbarrier == "Y"),
            hasRestroomBarrier: (response.restbarrier == "Y"),
            hasRunwayBarrier: (response.runwbarrier == "Y"),
            hasElevatorBarrier: (response.elevbarrier == "Y"),
            hasParkingLot: (response.parkinglot == "Y"),
            subVenues: response.mt13s.toDomain()
        )
        
        return Facility(
            id: response.mt10id,
            name: response.fcltynm,
            performanceCount: Int(response.mt13cnt) ?? 0,
            character: Constant.FacilityCharacteristic.findBy(name: response.fcltychartr),
            sidoName: nil, // Detail 요청 응답값에는 시/도 정보가 포함되지 않음.
            gugunName: nil, // Detail 요청 응답값에는 구/군 정보가 포함되지 않음.
            openYear: Int(response.opende.isEmpty ? "" : response.opende),
            detail: detailInfo
        )
    }
    
}

/**
 * `<db>` XML 요소를 나타내는 구조체로, 공연 시설의 상세 정보를 담음.
 */
struct FacilityDetailResponse: Codable, Hashable {
    /// 공연시설 이름
    let fcltynm: String
    /// 공연시설 id
    let mt10id: String
    /// 공연장 목록 수
    let mt13cnt: String
    /// 공연장 특성
    let fcltychartr: String
    /// nullable
    let opende: String
    /// 해외의 경우 0일 수 있음.
    let seatscale: String
    /// nullable
    let telno: String
    let relateurl: String
    let adres: String // nullable
    /// 해외의 경우 0
    let la: String
    /// 해외의 경우 0
    let lo: String
    /// Y || N
    let restaurant: String
    /// Y || N
    let cafe: String
    /// Y || N
    let store: String
    /// Y || N
    let nolibang: String
    /// Y || N
    let suyu: String
    /// Y || N
    let parkbarrier: String
    /// Y || N
    let restbarrier: String
    /// Y || N
    let runwbarrier: String
    /// Y || N
    let elevbarrier: String
    /// Y || N
    let parkinglot: String
    
    /// `<mt13s>` 태그에 해당하는 중첩된 공연장 목록
    let mt13s: PerformancePlaceListResponse
}

/**
 * `<mt13s>` XML 요소를 나타내는 구조체
 * 내부에 여러 개의 `<mt13>` 객체를 배열로 가짐.
 */
struct PerformancePlaceListResponse: Codable, Hashable {
    let mt13: [PerformancePlaceResponse]
    
    func toDomain() -> [SubVenue] {
        return mt13.map { $0.toDomain() }
    }
}

/**
 * `<mt13>` XML 요소를 나타내는 구조체
 * 개별 공연장의 상세 정보를 담음
 */
struct PerformancePlaceResponse: Codable, Hashable {
    let prfplcnm: String
    let mt13id: String
    let seatscale: String
    let stageorchat: String
    let stagepracat: String
    let stagedresat: String
    let stageoutdrat: String
    let disabledseatscale: String
    let stagearea: String
    
    func toDomain() -> SubVenue {
        return SubVenue(
            name: prfplcnm,
            id: mt13id,
            seatScale: Int(seatscale) ?? 0,
            hasOrchestraPit: (stageorchat == "Y"),
            hasPracticeRoom: (stagepracat == "Y"),
            hasDressingRoom: (stagedresat == "Y"),
            hasOutdoorStage: (stageoutdrat == "Y"),
            disabledSeatScale: Int(disabledseatscale),
            stageArea: stagearea.isEmpty ? nil : stagearea
        )
    }
}

enum FacilityDetailListResponseError: LocalizedError {
    case containNoContents
}
