//
//  ImageRecord.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import CoreLocation

// 이미지와 관련 메타데이터를 저장할 모델
struct ImageRecord {
    let uuid = UUID()
    let image: UIImage
    let creationDate: Date?
    let location: CLLocation?
}
