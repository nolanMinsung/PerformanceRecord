//
//  ImageCategory.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

enum ImageCategory {
    case performance(id: String)
    case record(id: String)
    
    /// 이미지가 저장될 하위 경로(Documents 폴더 안)
    var subpath: String {
        switch self {
        case .performance(let id):
            return "Images/Performances/\(id)"
        case .record(let id):
            return "Images/Reviews/\(id)"
        }
    }
}
