//
//  Diary.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

struct Diary: Identifiable, Hashable {
    let id: String
    let performanceID: String
    let createdAt: Date
    let viewedAt: Date
    let rating: Double
    let reviewText: String
    let diaryImageUUIDs: [String]
}
