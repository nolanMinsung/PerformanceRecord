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
        // TODO: 구현하기
        fatalError()
    }
    
    func fetchDetailFromLocal(id: String) async throws -> Performance {
        // TODO: 구현하기
        fatalError()
    }
    
    func fetchLikeFromLocal() async throws -> [Performance] {
        @UserDefault(key: .likePerformanceIDs, defaultValue: [])
        var likePerformancesID: [String]
        
        return try await Task.detached {
            let realm = try Realm()
            return realm.objects(PerformanceObject.self)
                .map { $0.toDomain() }
                .filter { likePerformancesID.contains($0.id) }
        }.value
    }
    
    func save(performance: Performance) async throws {
        // 포스터 이미지 저장 후 포스터 ID 상수에 저장
        let posterID = try await imageRepository.saveImage(urlString: performance.posterURL, category: .performance(id: performance.id))
        let detailImageUUIDs = try await withThrowingTaskGroup(
            of: (index: Int, uuid: String?).self,
            returning: [String].self,
            body: { group in
                let detailURLs = performance.detail?.detailImageURLs ?? []
                for (index, imageURL) in detailURLs.enumerated() {
                    group.addTask {
                        let uuid = try await self.imageRepository.saveImage(
                            urlString: imageURL,
                            category: .performance(id: performance.id)
                        )
                        return (index, uuid)
                    }
                }
                var indexedUUIDs = [(index: Int, uuid: String)]()
                for try await result in group {
                    if let uuid = result.uuid {
                        indexedUUIDs.append((index: result.index, uuid: uuid))
                    }
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
        
        try await Task.detached {
            let realm = try Realm()
            try realm.write {
                realm.add(performanceObject, update: .modified)
            }
        }.value
    }
    
    func delete(performanceID: String) async throws {
        // 이미지 먼저 삭제 - 포스터, 상세 이미지 모두
        try await imageRepository.deleteAllImages(of: .performance(id: performanceID))
        // --- 이미지 삭제 완료 ---
        
        try await Task.detached {
            let realm = try Realm()
            
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
                // Realm Object 삭제
                realm.delete(performanceObject)
            }
        }.value
    }
    
}
