//
//  DefaultPerformanceRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

import RealmSwift

@MainActor
final class DefaultPerformanceRepository: PerformanceRepository {
    
    let imageRepository: any ImageRepository
    let realm = try! Realm()
    
    init(imageRepository: some ImageRepository) {
        self.imageRepository = imageRepository
        print(realm.configuration.fileURL ?? "⚠️에러!! realm 주소 확인 불가")
    }
    
    func fetchDetailFromRemote(id: String) async throws -> Performance {
        // TODO: 구현하기
        fatalError()
    }
    
    func fetchDetailFromLocal(id: String) async throws -> Performance {
        // TODO: 구현하기
        fatalError()
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
        try realm.write {
            realm.add(performanceObject, update: .modified)
        }
        
    }
    
}
