//
//  RecordDetailUIModel.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/14/25.
//

import UIKit

struct RecordDetailUIModel: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.record == rhs.record
    }
    
    let record: Record
    let recordImageThumbnails: [UIImage]
    
    init(from record: Record) async throws {
        self.record = record
        do {
            // 엄밀하게는 ImageRepository의 의존성을 외부에서 주입받는 게 맞을 것 같긴 한데, 우선 구현체에 직접 의존하여 이미지를 로드하도록 구현함.
            self.recordImageThumbnails = try await DefaultImageRepository.shared.loadThumbnails(in: record)
        } catch {
            // 썸네일 가져오기에 실패했을 경우 원본 이미지 가져오기
            // 썸네일 기능 업데이트 전에 생성된 파일에 해당함.
            self.recordImageThumbnails = try await DefaultImageRepository.shared.loadImages(in: record)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(record)
    }
    
}

