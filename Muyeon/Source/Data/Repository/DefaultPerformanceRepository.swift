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
    
    let imageStoreService = FileManagerImageStoreService()
    let realm = try! Realm()
    
    init() {
        print(realm.configuration.fileURL)
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
        let posterUUID = try await FileManagerImageStoreService.downloadAndSaveImage(
            from: performance.posterURL,
            folderName: performance.id
        )
        
        let detailImageUUIDs = try await withThrowingTaskGroup(
            of: (index: Int, uuid: String?).self,
            returning: [String].self,
            body: { group in
                let detailURLs = performance.detail?.detailImageURLs ?? []
                for (index, imageURL) in detailURLs.enumerated() {
                    group.addTask {
                        let uuid = try await FileManagerImageStoreService.downloadAndSaveImage(
                            from: imageURL,
                            folderName: performance.id
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
            posterUUID: posterUUID,
            detailImageUUIDs: detailImageUUIDs
        )
        try realm.write {
            realm.add(performanceObject, update: .modified)
        }
        
    }
    
}
