//
//  RemoteImageDataSource.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import UIKit

import Kingfisher

actor DefaultRemoteImageDataSource: RemoteImageDataSource {
    
    static let shared = DefaultRemoteImageDataSource()
    private init() { }
    
    func download(from url: String) async throws -> ImageDataForSaving {
        guard let url = URL(string: url) else {
            fatalError()
        }
        let retrieveResult = try await KingfisherManager.shared.retrieveImage(with: url).image
        // 참고) GiF 파일도 .jpeg로 저장됨. (ex. https://www.kopis.or.kr/upload/pfmPoster/PF_PF273149_250902_102813.gif)
        guard let imageData = retrieveResult.jpegData(compressionQuality: 0.8) else {
            fatalError()
        }
        return ImageDataForSaving(data: imageData, type: .jpeg)
    }
    
}
