//
//  DefaultImageRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import UIKit

final class DefaultImageRepository: ImageRepository {
    
    static let shared = DefaultImageRepository(
        remoteDataSource: DefaultRemoteImageDataSource.shared,
        localDataSource: DefaultLocalImageDataSource.shared
    )
    
    private let remoteDataSource: any RemoteImageDataSource
    private let localDataSource: any LocalImageDataSource
    
    private init(remoteDataSource: RemoteImageDataSource, localDataSource: LocalImageDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func saveImage(urlString: String, category: ImageCategory) async throws -> String {
        let imageData = try await remoteDataSource.download(from: urlString)
        let imageID = UUID().uuidString
        try await localDataSource.save(imageData: imageData, imageID: imageID, category: category)
        return imageID
    }
    
    func saveImage(data: ImageDataForSaving, category: ImageCategory) async throws -> String {
        let imageID = UUID().uuidString
        try await localDataSource.save(imageData: data, imageID: imageID, category: category)
        return imageID
    }
    
    func loadImage(with id: String, category: ImageCategory) async throws -> UIImage {
        try await localDataSource.load(imageID: id, category: category)
    }
    
    func deleteImage(with id: String, category: ImageCategory) async throws {
        try await localDataSource.delete(imageID: id, category: category)
    }
    
    func deleteAllImages(of performance: Performance, category: ImageCategory) async throws {
        try await localDataSource.deleteAllImages(of: performance, category: category)
    }
}
