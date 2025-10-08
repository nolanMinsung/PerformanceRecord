//
//  DefaultRecordRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import Foundation

import RealmSwift
import RxSwift
import RxRelay

enum DefaultRecordRepositoryError: LocalizedError {
    case diaryNotHavingPerformance
}

actor DefaultRecordRepository: RecordRepository {
    
    static let shared = DefaultRecordRepository(
        imageRepository: DefaultImageRepository.shared
    )
    
    nonisolated private let recordUpdatedRelay = PublishRelay<Void>()
    nonisolated var recordUpdated: Observable<Void> {
        return recordUpdatedRelay.asObservable()
    }
    
    private let imageRepository: any ImageRepository
    private init(imageRepository: any ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func createDiary(_ diary: Record, images imageData: [ImageDataForSaving]) async throws {
        // 플로우
        // ---- 트랜잭션 1 시작 ----
        // - 기록할 performanceObject 먼저 찾기
        // - 기록할 performanceObject에 RecordObject 추가하기
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
        
        let createdDiaryID = try await Task.detached {
            let realm = try Realm()
            guard let performanceObject = realm.objects(PerformanceObject.self)
                .filter({ $0.id == diary.performanceID })
                .first
            else {
                throw DefaultPerformanceRepositoryError.performanceObjectNotFound
            }
            let diaryID = UUID().uuidString
            let recordObject = RecordObject.create(
                id: diaryID,
                viewedAt: diary.viewedAt,
                rating: diary.rating,
                reviewText: diary.reviewText
            )
            try realm.write {
                performanceObject.records.append(recordObject)
            }
            return diaryID
        }.value
        
        // 생성한 DiaryObject의 id를 이용해 폴더를 만들고 그 폴더에 이미지 저장(폴더의 이름이 일기의 ID)
        let savedDiaryImageIDs = try await saveImagesToFileManager(diaryID: createdDiaryID, imageData: imageData)
        
        // FileManager에 저장한 이미지 ID 가져와서 Realm에 반영
        try await Task.detached {
            let realm = try Realm()
            try realm.write {
                guard let diaryObject = realm.objects(RecordObject.self)
                    .filter({ $0.id == createdDiaryID })
                    .first
                else {
                    fatalError()
                }
                diaryObject.diaryImageUUIDs.append(objectsIn: savedDiaryImageIDs)
            }
        }.value
        recordUpdatedRelay.accept(())
    }
    
    func fetchDiaries(of performance: Performance) async throws -> [Record] {
        return try await Task.detached {
            let realm = try Realm()
            return try realm.objects(RecordObject.self)
                .filter({$0.performance.first?.id == performance.id})
                .map { try $0.toDomain() }
        }.value
    }
    
    func fetchAllDiaries() async throws -> [Record] {
        return try await Task.detached {
            let realm = try Realm()
            return try realm.objects(RecordObject.self)
                .map { try $0.toDomain() }
        }.value
    }
    
    func deleteRecord(_ record: Record) async throws {
        // 이미지가 있을 경우, 이미지 먼저 삭제
        if !record.diaryImageUUIDs.isEmpty {
            try await imageRepository.deleteAllImages(of: .record(id: record.id))
            print("Record 이미지 삭제 완료")
        }
        try await Task.detached {
            let realm = try Realm()
            let recordObject = realm.objects(RecordObject.self).filter({ $0.id == record.id })
            try realm.write {
                realm.delete(recordObject)
            }
            print("DB에서 Record 삭제 완료")
            #if DEBUG
            guard let performance = realm.objects(PerformanceObject.self)
                .filter({ $0.id == record.performanceID })
                .first
            else {
                return
            }
            assert(performance.records.filter({ $0.id == record.id }).isEmpty, "삭제 안된듯?")
            print("Debug Mode: Performance Object의 List에서 제거된 것 확인.")
            #endif
        }.value
        recordUpdatedRelay.accept(())
    }
    
}


private extension DefaultRecordRepository {
    
    func saveImagesToFileManager(diaryID: String, imageData: [ImageDataForSaving]) async throws -> [String] {
        let imageUUIDs = try await withThrowingTaskGroup(
            of: (index: Int, imageID: String).self,
            returning: [String].self,
            body: { group in
                for (index, dataForSaving) in imageData.enumerated() {
                    group.addTask {
                        let imageUUID = try await self.imageRepository.saveImage(data: dataForSaving, to: .record(id: diaryID))
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
