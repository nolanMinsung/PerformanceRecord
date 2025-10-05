//
//  DiaryObject.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

import RealmSwift

// MARK: - DiaryObject (공연 후기/일기)

final class DiaryObject: Object {
    // Primary Key
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    
    // MARK: - Performance 정보 (1:1 관계)
    // PerformanceObject의 id를 참조하는 Link
    @Persisted var performance: PerformanceObject?
    
    // MARK: - 날짜/시각 정보
    @Persisted var createdAt: Date = Date()   // 공연 기록 생성 날짜 (일기 작성 시점)
    @Persisted var viewedAt: Date    // 공연을 관람한 날짜 및 시각
    
    // MARK: - 후기 정보
    @Persisted var rating: Double = 0.0     // 별점 (0.0 ~ 5.0, 소수점 첫째 자리)
    @Persisted var reviewText: String = ""   // 내 기록 (후기 내용)
    
    // MARK: - 첨부 이미지 및 출연진
    
    // 기록용 이미지 UUID 목록 (로컬 FileManager 저장 파일명, 메타데이터는 파일 시스템에 저장)
    @Persisted var diaryImageUUIDs: RealmSwift.List<String>
    
    // MARK: Relationships (N:N 관계의 '1' 쪽)
    // 이 일기에 출연한 모든 출연진 목록 (N:N 관계의 List)
    @Persisted var castMembers: RealmSwift.List<CastMemberObject>
}

extension DiaryObject {
    
    static func create(
        performance: PerformanceObject,
        viewedAt: Date,
        rating: Double,
        reviewText: String,
        imageUUIDs: [String] = []
    ) -> DiaryObject  {
        let object = DiaryObject()
        object.performance = performance
        object.createdAt = .now
        object.viewedAt = viewedAt
        object.rating = max(0, min(rating, 5.0))
        object.reviewText = reviewText
        object.diaryImageUUIDs.append(objectsIn: imageUUIDs)
        return object
    }
    
}


extension DiaryObject {
    
    func toDomain() -> Diary {
        return Diary(
            performance: self.performance?.toDomain(),
            createdAt: self.createdAt,
            viewedAt: self.viewedAt,
            rating: self.rating,
            reviewText: self.reviewText,
            diaryImageUUIDs: Array(self.diaryImageUUIDs)
        )
    }
    
}

