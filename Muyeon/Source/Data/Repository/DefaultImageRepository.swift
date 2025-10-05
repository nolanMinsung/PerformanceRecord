//
//  DefaultImageRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import UIKit

final class DefaultImageRepository: ImageRepository {
    
    private let remoteDataSource: any RemoteImageDataSource
    private let localDataSource: any LocalImageDataSource
    
    init(remoteDataSource: RemoteImageDataSource, localDataSource: LocalImageDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func saveImage(urlString: String, category: ImageCategory) async throws -> String {
        let imageData = try await remoteDataSource.download(from: urlString)
        let imageID = UUID().uuidString
        try localDataSource.save(imageData: imageData, imageID: imageID, category: category)
        return imageID
    }
    
    func saveImage(data: Data, category: ImageCategory) async throws -> String {
        let imageID = UUID().uuidString
        try localDataSource.save(imageData: data, imageID: imageID, category: category)
        return imageID
    }
    
    func loadImage(with id: String, category: ImageCategory) async throws -> UIImage {
        try localDataSource.load(imageID: id, category: category)
    }
    
}
