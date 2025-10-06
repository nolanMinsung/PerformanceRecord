//
//  DefaultDiaryRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

import RealmSwift

enum DefaultDiaryRepositoryError: LocalizedError {
    case diaryNotHavingPerformance
}

final class DefaultDiaryRepository: DiaryRepository {
    
    let imageRepository: any ImageRepository
    let realm = try! Realm()
    
    init(imageRepository: any ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func createDiary(_ diary: Diary, images imageData: [ImageDataForSaving]) async throws {
        // 플로우
        // ---- 트랜잭션 1 시작 ----
        // - 기록할 performanceObject 먼저 찾기
        // - 기록할 performanceObject에 DiaryObject 추가하기
        // ---- 트랜잭션 1 끝 ----
        //       |
        //       |  동기 작업
        //       V
        // - 추가한 DiaryObject의 id를 활용해서 FileManager에 폴더를 만들고 이미지 저장하기
        //       |
        //       |  동기 작업
        //       V
        // ---- 트랜잭션 2 시작 ----
        // - 저장한 이미지들의 ID 배열을 추가한 DiaryObject의 diaryImageUUIDs 속성에 추가하기
        // ---- 트랜잭션 2 끝 ----
        
        var createdDiaryID: String = ""
        try realm.write {
            guard diary.performance != nil else {
                throw DefaultDiaryRepositoryError.diaryNotHavingPerformance
            }
            guard let performanceObject = realm.objects(PerformanceObject.self)
                .filter({ $0.id == diary.performance?.id })
                .first
            else {
                throw DefaultPerformanceRepositoryError.performanceObjectNotFound
            }
            
            let diaryObject = DiaryObject.create(
                performance: performanceObject,
                viewedAt: diary.viewedAt,
                rating: diary.rating,
                reviewText: diary.reviewText
            )
            realm.add(diaryObject, update: .modified)
            createdDiaryID = diaryObject.id
        }
        
        // 이미지 저장
        let savedDiaryImageIDs = try await saveImagesToFileManager(diaryID: createdDiaryID, imageData: imageData)
        
        // FileManager에 저장한 이미지 ID 가져와서 Realm에 반영
        try realm.write {
            guard let diaryObject = realm.objects(DiaryObject.self)
                .filter({ $0.id == createdDiaryID })
                .first
            else {
                fatalError()
            }
            diaryObject.diaryImageUUIDs.append(objectsIn: savedDiaryImageIDs)
        }
        
    }
    
    func fetchDiaries(of performance: Performance) throws -> [Diary] {
        return realm.objects(DiaryObject.self)
            .filter({$0.performance?.id == performance.id})
            .map { $0.toDomain() }
    }
    
}


private extension DefaultDiaryRepository {
    
    func saveImagesToFileManager(diaryID: String, imageData: [ImageDataForSaving]) async throws -> [String] {
        let imageUUIDs = try await withThrowingTaskGroup(
            of: (index: Int, imageID: String).self,
            returning: [String].self,
            body: { group in
                for (index, dataForSaving) in imageData.enumerated() {
                    group.addTask {
                        let imageUUID = try await self.imageRepository.saveImage(data: dataForSaving, category: .diary(id: diaryID))
                        return (index, imageUUID)
                    }
                }
                
                var indexedUUIDs: [(index: Int, UUID: String)] = []
                for try await resultItem in group {
                    indexedUUIDs.append((resultItem.index, resultItem.imageID))
                }
                let sortedUUIDs = indexedUUIDs
                    .sorted { $0.index < $1.index }
                    .map(\.UUID)
                
                return sortedUUIDs
            }
        )
        
        return imageUUIDs
    }
    
}
