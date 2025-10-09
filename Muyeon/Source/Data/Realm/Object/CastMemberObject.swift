//
//  CastMemberObject.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

import RealmSwift

// MARK: - CastMemberObject (출연진 정보)

final class CastMemberObject: Object {
    // Primary Key: N:N 관계에서 고유성을 확보하고 추후 전역적으로 사용/수정 가능하도록 UUID 사용
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    
    // 필수 정보
    @Persisted var name: String = "" // 이름 (사용자 입력)
    
    // 추후 변경 및 추가 예정인 정보들 (현재는 nil 허용)
    @Persisted var birthDate: Date?    // 생년월일 (나이 대신 더 정확한 데이터)
    @Persisted var gender: String?     // 성별
    @Persisted var notes: String?      // 기타 필요한 점 (예: 특이사항, MBTI 등)
    
    // 출연진 프로필 사진 UUID (로컬 FileManager 저장 파일명)
    @Persisted var profileImageUUID: String?
    
    // MARK: Relationships (N:N 관계의 'N' 쪽 - 역참조)
    // 이 출연진이 등장한 모든 일기 목록 (LinkingObjects를 사용한 역참조)
    @Persisted(originProperty: "castMembers")
    var records: LinkingObjects<RecordObject>
    
    convenience init(name: String, profileImageID: String? = nil) {
        self.init()
        self.name = name
        self.profileImageUUID = profileImageID
    }
}
