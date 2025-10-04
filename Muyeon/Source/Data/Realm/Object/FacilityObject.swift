//
//  FacilityObject.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation
import RealmSwift

// MARK: - Facility

final class FacilityObject: Object {
    // Primary Key
    @Persisted(primaryKey: true) var id: String // mt10id
    
    // 필수 공통 정보
    @Persisted var name: String = "" // fcltynm
    @Persisted var performanceCount: Int = 0 // mt13cnt (공연장 개수)
    
    // Constant 타입 (String으로 가정)
    @Persisted var character: String = "" // fcltychartr (시설 특성)
    @Persisted var sidoName: String? // sidonm (시도명)
    @Persisted var gugunName: String? // gugunnm (구군명)
    
    // 부가 정보
    @Persisted var openYear: Int? // opende (개관연도)

    // MARK: Detail (FacilityDetail 통합)
    @Persisted var totalSeatScale: Int = 0  // seatscale (총 좌석수)
    @Persisted var telNumber: String?   // telno (전화번호)
    @Persisted var relatedURL: String?     // relateurl
    @Persisted var address: String?     // adres (주소)
    
    // 위치 정보
    @Persisted var latitude: Double?     // la (위도)
    @Persisted var longitude: Double?    // lo (경도)
    
    // 편의 시설 정보 (Bool)
    @Persisted var hasRestaurant: Bool = false  // restaurant
    @Persisted var hasCafe: Bool = false        // cafe
    @Persisted var hasStore: Bool = false       // store
    @Persisted var hasNolibang: Bool = false    // nolibang (놀이방)
    @Persisted var hasSuyusil: Bool = false     // suyu (수유실)
    
    // 장애인 편의시설 정보 (Bool)
    @Persisted var hasParkingBarrier: Bool = false // parkbarrier
    @Persisted var hasRestroomBarrier: Bool = false // restbarrier
    @Persisted var hasRunwayBarrier: Bool = false // runwbarrier
    @Persisted var hasElevatorBarrier: Bool = false // elevbarrier
    @Persisted var hasParkingLot: Bool = false  // parkinglot
    
    // MARK: Relationships (1:N)
    // SubVenue와의 1:N 관계: SubVenueObject들을 저장하는 List
    @Persisted var subVenues = RealmSwift.List<SubVenueObject>()
}

// MARK: - SubVenue

final class SubVenueObject: Object {
    @Persisted(primaryKey: true) var id: String // mt13id
    @Persisted var name: String = "" // prfplcnm (공연장 이름)
    @Persisted var seatScale: Int = 0 // seatscale (좌석 수)
    
    // 기타 상세 정보 필드 (Bool, Int, String)
    @Persisted var hasOrchestraPit: Bool = false      // stageorchat
    @Persisted var hasPracticeRoom: Bool = false      // stagepracat
    @Persisted var hasDressingRoom: Bool = false      // stagedresat
    @Persisted var hasOutdoorStage: Bool = false      // stageoutdrat
    @Persisted var disabledSeatScale: Int?    // disabledseatscale (장애인 좌석 수)
    @Persisted var stageArea: String?         // stagearea (무대 면적)

    // MARK: Relationships (N:1)
    // 자신을 참조하는 FacilityObject (Inverse Relationship)
    @Persisted(originProperty: "subVenues") var facility: LinkingObjects<FacilityObject>
}
