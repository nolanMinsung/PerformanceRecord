//
//  PerformanceObject.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

import RealmSwift

// MARK: - Performance

final class PerformanceObject: Object {
    // Primary Key
    @Persisted(primaryKey: true) var id: String // mt20id (공연ID)
    @Persisted var createdDate: Date
    
    // 필수 공통 정보
    @Persisted var name: String = "" // prfnm (공연명)
    @Persisted var startDate: Date // prfpdfrom (공연시작일)
    @Persisted var endDate: Date // prfpdto (공연종료일)
    @Persisted var facilityFullName: String = "" // fcltynm (공연시설명)
    
    // 이미지 파일 UUID (로컬 FileManager 저장 파일명)
    @Persisted var posterImageUUID: String? // poster (포스터이미지경로 대체)
    
    // Constant 타입 (String으로 가정)
    @Persisted var area: String = "" // area (공연지역)
    @Persisted var genre: String = "" // genrenm (공연장르)
    @Persisted var state: String = "" // prfstate (공연상태)
    
    // 부가 정보
    @Persisted var openRun: Bool = false // openrun (오픈런)

    // MARK: Detail (PerformanceDetail 통합)
    @Persisted var cast: String? // prfcast (출연진)
    @Persisted var crew: String? // prfcrew (제작진)
    @Persisted var runtime: String? // prfruntime
    @Persisted var ageLimit: String? // prfage (관람 연령)
    @Persisted var enterpriseName: String? // entrpsnm(기획제작사)
    @Persisted var enterpriseNameP: String? // entrpsnmP(제작사)
    @Persisted var enterpriseNameA: String? // entrpsnmA(기획사)
    @Persisted var enterpriseNameH: String? // entrpsnmH(주최)
    @Persisted var enterpriseNameS: String? // entrpsnmS(주관)
    @Persisted var priceGuidance: String? // pcseguidance (가격 정보)
    @Persisted var story: String? // sty (줄거리)
    @Persisted var visitingKorea: Bool = false // visit(내한)
    @Persisted var child: Bool = false // child(아동)
    @Persisted var daehakro: Bool = false // daehakro(대학로)
    @Persisted var isFestival: Bool = false // festival(축제)
    @Persisted var musicalLicense: Bool = false // musicallicense(뮤지컬 라이센스)
    @Persisted var musicalCreate: Bool = false // musicalcreate(뮤지컬 창작)
    @Persisted var updateDate: Date? // updatedate(최종수정일)
    @Persisted var facilityID: String? // mt10id (Facility의 ID)
    @Persisted var detailDateGuidance: String? // dtguidance (상세 일정)
    
    // 소개 이미지 파일 UUID 목록 (로컬 FileManager 저장 파일명)
    // List<String>을 사용해 String 배열을 저장.
    @Persisted var detailImageUUIDs: List<String>
    
    // MARK: Relationships (1:N)
    // RelatedLink와의 1:N 관계: RelatedLinkObject들을 저장하는 List
    @Persisted var relatedLinks = RealmSwift.List<RelatedLinkObject>()
    
    // Record와의 1:N 관계
    @Persisted var records = RealmSwift.List<RecordObject>()
}

// MARK: - RelatedLink

final class RelatedLinkObject: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString // 고유 ID (UUID)
    @Persisted var name: String = "" // relatenm
    @Persisted var url: String = "" // relateurl
    
    // MARK: Relationships (N:1)
    // 자신을 참조하는 PerformanceObject (Inverse Relationship)
    @Persisted(originProperty: "relatedLinks") var performance: LinkingObjects<PerformanceObject>
}


extension PerformanceObject {
    
    func toDomain() throws -> Performance {
        // RelatedLink 변환
        let domainRelatedLinks = Array(self.relatedLinks.map { linkObject -> RelatedLink in
            return RelatedLink(name: linkObject.name, url: linkObject.url)
        })

        // PerformanceDetail 변환 (옵셔널)
        let domainDetail: PerformanceDetail?
        // Realm Object에서는 Detail 정보가 분리되어 있지 않지만,
        // 도메인 모델과 맞추기 위해 Optional 속성 중 하나를 기준으로 존재 여부를 판단.
        if let facilityID = self.facilityID {
            domainDetail = PerformanceDetail(
                cast: self.cast ?? "",
                crew: self.crew ?? "",
                runtime: self.runtime ?? "",
                ageLimit: self.ageLimit ?? "",
                enterpriseName: self.enterpriseName,
                enterpriseNameP: self.enterpriseNameP,
                enterpriseNameA: self.enterpriseNameA,
                enterpriseNameH: self.enterpriseNameH,
                enterpriseNameS: self.enterpriseNameS,
                priceGuidance: self.priceGuidance ?? "",
                story: self.story ?? "",
                visitingKorea: self.visitingKorea,
                child: self.child,
                daehakro: self.daehakro,
                isFestival: self.isFestival,
                musicalLicense: self.musicalLicense,
                musicalCreate: self.musicalCreate,
                updateDate: self.updateDate ?? Date(), // Realm Object의 Optional을 Domain의 Non-Optional에 맞춤
                facilityID: facilityID,
                detailDateGuidance: self.detailDateGuidance ?? "",
                detailImageURLs: [], // URL을 알 수 없으므로 비워둠.
                detailImageIDs: Array(detailImageUUIDs),
                relatedLinks: domainRelatedLinks
            )
        } else {
            domainDetail = nil
        }
        
        // 3. Performance 변환
        return Performance(
            id: self.id,
            name: self.name,
            startDate: self.startDate,
            endDate: self.endDate,
            facilityFullName: self.facilityFullName,
            posterURL: "", // UUID만 있으므로 URL은 비워둠.
            posterImageID: posterImageUUID,
            area: Constant.AdminAreaCode(rawValue: self.area) ?? .unknown,
            genre: Constant.Genre(rawValue: self.genre) ?? .unknown,
            openRun: self.openRun,
            state: Constant.PerformanceState(rawValue: self.state) ?? .unknown,
            records: try records.map({ try $0.toDomain() }),
            detail: domainDetail
        )
    }
    
}


extension PerformanceObject {

    /// Performance 도메인 모델과 이미지 UUID를 사용하여 Realm 객체를 생성하는 타입 메서드
    static func create(
        from performance: Performance,
        posterUUID: String?,
        detailImageUUIDs: [String]
    ) -> PerformanceObject {
        
        let object = PerformanceObject()
        object.createdDate = .now
        
        // MARK: - 필수 공통 정보
        object.id = performance.id
        object.name = performance.name
        object.startDate = performance.startDate
        object.endDate = performance.endDate
        object.facilityFullName = performance.facilityFullName
        
        // Constant 타입 (String 원시값 사용)
        object.area = performance.area.rawValue
        object.genre = performance.genre.rawValue
        object.state = performance.state.rawValue
        object.openRun = performance.openRun
        
        // 이미지 UUID 참조
        object.posterImageUUID = posterUUID
        
        // MARK: - Detail 정보 통합
        if let detail = performance.detail {
            object.cast = detail.cast
            object.crew = detail.crew
            object.runtime = detail.runtime
            object.ageLimit = detail.ageLimit
            object.enterpriseName = detail.enterpriseName
            object.enterpriseNameP = detail.enterpriseNameP
            object.enterpriseNameA = detail.enterpriseNameA
            object.enterpriseNameH = detail.enterpriseNameH
            object.enterpriseNameS = detail.enterpriseNameS
            object.priceGuidance = detail.priceGuidance
            object.story = detail.story
            object.visitingKorea = detail.visitingKorea
            object.child = detail.child
            object.daehakro = detail.daehakro
            object.isFestival = detail.isFestival
            object.musicalLicense = detail.musicalLicense
            object.musicalCreate = detail.musicalCreate
            object.updateDate = detail.updateDate
            object.facilityID = detail.facilityID
            object.detailDateGuidance = detail.detailDateGuidance
            
            // Detail Image UUIDs 목록 저장
            object.detailImageUUIDs.append(objectsIn: detailImageUUIDs)
            
            // RelatedLink Object 생성 및 연결
            let relatedLinkObjects = detail.relatedLinks.map { link -> RelatedLinkObject in
                let linkObject = RelatedLinkObject()
                linkObject.name = link.name
                linkObject.url = link.url
                // Inverse Relationship은 자동으로 설정됨.
                return linkObject
            }
            object.relatedLinks.append(objectsIn: relatedLinkObjects)
        }
        
        return object
    }
}
