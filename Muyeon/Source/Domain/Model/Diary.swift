//
//  Diary.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

struct Diary {
    var performance: Performance?
    var createdAt: Date
    var viewedAt: Date
    var rating: Double
    var reviewText: String
    var diaryImageUUIDs: [String]
}
