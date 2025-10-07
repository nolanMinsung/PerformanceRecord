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
    
    func saveImage(urlString: String, to category: ImageCategory) async throws -> String {
        let imageData = try await remoteDataSource.download(from: urlString)
        let imageID = UUID().uuidString
        try await localDataSource.save(imageData: imageData, imageID: imageID, category: category)
        return imageID
    }
    
    func saveImage(data: ImageDataForSaving, to category: ImageCategory) async throws -> String {
        let imageID = UUID().uuidString
        try await localDataSource.save(imageData: data, imageID: imageID, category: category)
        return imageID
    }
    
    func loadImage(with id: String, in category: ImageCategory) async throws -> UIImage {
        try await localDataSource.load(imageID: id, category: category)
    }
    
    func loadImages(in diary: Record) async throws -> [UIImage] {
        let imageIDs = diary.diaryImageUUIDs
        
        return try await withThrowingTaskGroup(
            of: (index: Int, image: UIImage).self,
            returning: [UIImage].self,
            body: { group in
                for item in imageIDs.enumerated() {
                    group.addTask {
                        let image = try await self.localDataSource.load(imageID: item.element, category: .diary(id: diary.id))
                        return (item.offset, image)
                    }
                }
                var sortedArray: [(index: Int, image: UIImage)] = []
                for try await result in group {
                    sortedArray.append(result)
                }
                let sortedImage = sortedArray
                    .sorted { $0.index < $1.index }
                    .map(\.image)
                return sortedImage
            }
        )
    }
    
    func deleteImage(with id: String, in category: ImageCategory) async throws {
        try await localDataSource.delete(imageID: id, category: category)
    }
    
    func deleteAllImages(of category: ImageCategory) async throws {
        try await localDataSource.deleteAllImages(in: category)
    }
}
