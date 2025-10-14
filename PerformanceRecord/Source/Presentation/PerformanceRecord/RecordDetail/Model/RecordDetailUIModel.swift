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
    let recordImages: [UIImage]
    
    init(from record: Record) async throws {
        self.record = record
        self.recordImages = try await DefaultImageRepository.shared.loadImages(in: record)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(record)
    }
    
}

