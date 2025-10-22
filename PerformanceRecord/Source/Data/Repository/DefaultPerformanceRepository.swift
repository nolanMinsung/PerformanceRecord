//
//  DefaultPerformanceRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

import RealmSwift

enum DefaultPerformanceRepositoryError: LocalizedError {
    case performanceObjectNotFound
}


actor DefaultPerformanceRepository: PerformanceRepository {
    
    static let shared = DefaultPerformanceRepository(
        imageRepository: DefaultImageRepository.shared
    )
    
    private let imageRepository: any ImageRepository
    
    private init(imageRepository: some ImageRepository) {
        self.imageRepository = imageRepository
        if let fileURL = try? Realm().configuration.fileURL?.absoluteString {
            print(fileURL)
        } else {
            print("⚠️에러!! realm 주소 확인 불가")
        }
    }
    
    func fetchDetailFromRemote(id: String) async throws -> Performance {
        return try await NetworkManager.requestValue(
            router: .getPerformanceDetail(apiKey: InfoPlist.apiKey, performanceID: id),
            decodingType: PerformanceDetailListResponse.self
        )
        .toDomain()
    }
    
    func fetchDetailFromLocal(id: String) async throws -> Performance {
        let realm = try await Realm.open()
        guard let performanceObject = realm.object(ofType: PerformanceObject.self, forPrimaryKey: id) else {
            throw DefaultPerformanceRepositoryError.performanceObjectNotFound
        }
        return try performanceObject.toDomain()
    }
    
    // MARK: - Creating Realm in Actor-isolated Context
    /// `MainActor`가 아닌 `actor`에서 `Realm` 인스턴스를 생성해야 할 때...
    /// 공식 문서에서는 `try await Realm(actor: ... )`를 쓰라고 되어있는데, 이렇게 하면 Swift 6 Language Mode에서 에러 남.
    /// 문제의 그 문서:
    /// https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/use-realm-with-actors/#write-to-an-actor-isolated-realm
    /// 이를 해결하기 위한 workaround가 `try await Realm.open()` 임.
    /// 이제 `actor-isolated` `Realm` 인스턴스를 생성할 때 `Realm`에서 `actor`를 추론해서, 직접 `actor`를 넘겨주지 말아야 한다고 함(should).
    /// ㄴ참고: https://github.com/realm/realm-swift/releases/tag/v10.54.0
    
    func fetchAllPerformanceListFromLocal() async throws -> [Performance] {
        let realm = try await Realm.open()
        return try realm .objects(PerformanceObject.self).map { try $0.toDomain() }
    }
    
    func fetchLikeFromLocal() async throws -> [Performance] {
        @UserDefault(key: .likePerformanceIDs, defaultValue: [])
        var likePerformancesID: [String]
        let realm = try await Realm.open()
        return try realm.objects(PerformanceObject.self)
            .map { try $0.toDomain() }
            .filter { likePerformancesID.contains($0.id) }
    }
    
    func fetchMostViewedFromLocal() async throws -> Performance? {
        let realm = try await Realm.open()
        
        // 현재는 메모리에 performanceObject들을 모두 올려놓고 sorting 중.
        // records.count를 기준으로 DB(Realm)에서 정렬을 시도하면 런타임 에러 발생
        // (아마 count를 무시하고 records 자체만을 기준으로 정렬을 시도하는 듯.)
        // DB에서 자체적으로 정렬 후 값을 반환하면 훨씬 빠르나, 이를 활용하기 위해서는
        // PerformanceObject에 recordCount와 같은 별도의 attribute를 추가해 주어야 함.
        //  + record 정보 바뀔 때마다 recordCount 업데이트하는 로직 추가
        //  + DB 스키마 마이그레이션 필요
        
        // 현재는 우선 Swift Collection의 내장 sorted 함수를 직접 사용하는 방법으로 구현
        let performanceWithMaxRecords = realm.objects(PerformanceObject.self)
            .sorted(by: { $0.records.count > $1.records.count })
            .first
        
        return try performanceWithMaxRecords?.toDomain()
    }
    
    func save(performance: Performance) async throws {
        // 포스터 이미지 저장 후 포스터 ID 상수에 저장
        let posterID = try await imageRepository.saveImage(
            urlString: performance.posterURL,
            to: .performance(id: performance.id)
        )
        
        let detailImageUUIDs = try await withThrowingTaskGroup(
            of: (index: Int, uuid: String).self,
            returning: [String].self,
            body: { group in
                let detailURLs = performance.detail?.detailImageURLs ?? []
                for (index, imageURL) in detailURLs.enumerated() {
                    group.addTask {
                        let uuid = try await self.imageRepository.saveImage(
                            urlString: imageURL,
                            to: .performance(id: performance.id)
                        )
                        return (index, uuid)
                    }
                }
                var indexedUUIDs = [(index: Int, uuid: String)]()
                for try await result in group {
                    indexedUUIDs.append((index: result.index, uuid: result.uuid))
                }
                
                let sortedUUIDs = indexedUUIDs
                    .sorted { $0.index < $1.index }
                    .map(\.uuid)
                
                return sortedUUIDs
            }
        )
        
        let performanceObject = PerformanceObject.create(
            from: performance,
            posterUUID: posterID,
            detailImageUUIDs: detailImageUUIDs
        )
        
        // --- Performance 정보를 로컬 DB에 저장 시도 시, 이미 존재하는 경우 ---
        
        // Performance가 새로 저장되면 이미지 파일 ID와 RelatedLink들도 업데이트됨.
        // 이 속성들이 업데이트되면 기존 속성에 해당하는 데이터들은 삭제해야 함.(이미지 파일, RelatedLinkObject 레코드)
        // 이때 업데이트 후에도 삭제할 기존 데이터들 정보를 삭제 시 활용하기 위해서
        // 기존 공연 정보가 있을 경우 이미지 ID와 RelatedLink들을 별도 변수에 보관.
        var oldPosterIDToDelete: String? = nil
        var oldDetailImageIDListToDelete: [String]? = nil
        var oldRelatedLinks: List<RelatedLinkObject>? = nil
        
        // 반대로 Record 정보는 보관해야 함.
        // Performance가 새로 저장되면 기존 PerformanceObject가 가리키던 RecordObject 정보(List<RecordObject>? 타입의 속성)가 삭제됨.
        // Performance가 업데이트되기 전에 record들을 가리키는 정보를 별도로 보관 후, 업데이트한 후에 이를 새로 저장된 Performance에 공연 기록을 저장할 때 사용.
        var oldRecords: List<RecordObject>? = nil
        
        let realm = try await Realm.open()
        
        if let oldPerformanceObject = realm.object(ofType: PerformanceObject.self, forPrimaryKey: performance.id) {
            // 기존에 공연이 있을 경우 업데이트 후 삭제할 데이터(이미지) 정보들을 별도로 보관
            oldPosterIDToDelete = oldPerformanceObject.posterImageUUID
            oldDetailImageIDListToDelete = Array(oldPerformanceObject.detailImageUUIDs)
            oldRelatedLinks = oldPerformanceObject.relatedLinks
            // 기존에 공연이 있을 경우 보관해야 할 데이터 (공연기록 List) 정보들을 별도로 보관
            oldRecords = oldPerformanceObject.records
        }
        try realm.write {
            realm.add(performanceObject, update: .all)
            // 업데이트된 performance 레코드에 기존 공연 기록 List 반영
            if let oldRecords {
                performanceObject.records = oldRecords
            }
            // 기존 relatedLink 레코드들 삭제
            if let oldRelatedLinks {
                realm.delete(oldRelatedLinks)
            }
        }
        
        // 새 공연 정보로 업데이트가 끝나면 기존 이미지들 순차적으로 삭제
        if let oldPosterIDToDelete {
            try await self.imageRepository.deleteImage(with: oldPosterIDToDelete, in: .performance(id: performance.id))
        }
        if let oldDetailImageIDListToDelete {
            for imageID in oldDetailImageIDListToDelete {
                try await imageRepository.deleteImage(with: imageID, in: .performance(id: performance.id))
            }
        }
    }
    
    func delete(performanceID: String) async throws {
        // 이미지 먼저 삭제 - 포스터, 상세 이미지 모두
        try await imageRepository.deleteAllImages(of: .performance(id: performanceID))
        // --- 이미지 삭제 완료 ---
        
        let realm = try await Realm.open()
        
        // Realm Object 부터 가져오자
        guard let performanceObject = realm.objects(PerformanceObject.self)
            .filter({ $0.id == performanceID })
            .first
        else {
            return
        }
        
        try realm.write {
            // RelatedLinkObject 삭제
            realm.delete(performanceObject.relatedLinks)
            // RecoredObject 삭제
            realm.delete(performanceObject.records)
            // Realm Object 삭제
            realm.delete(performanceObject)
        }
    }
    
}
