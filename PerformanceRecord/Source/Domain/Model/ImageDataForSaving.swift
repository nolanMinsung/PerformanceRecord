//
//  ImageDataForSaving.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UniformTypeIdentifiers

// 앱 전역에서 이미지를 저장할 때 사용할 Data 값과 파일 타입을 같이 저장
struct ImageDataForSaving {
    let data: Data
    let type: UTType
}
