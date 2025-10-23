//
//  FetchRecordImagesUseCase.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/23/25.
//

import UIKit

protocol FetchRecordImagesUseCase {
    func execute(record: Record) async throws -> [UIImage]
}


final class DefaultFetchRecordImagesUseCase: FetchRecordImagesUseCase {
    
    private let imageDataSource: any LocalImageDataSource
    
    init(imageDataSource: any LocalImageDataSource) {
        self.imageDataSource = imageDataSource
    }
    
    func execute(record: Record) async throws -> [UIImage] {
        let imageIDList = record.recordImageUUIDs
        var resultImages: [UIImage] = []
        resultImages.reserveCapacity(5)
//        for recordImageUUID in record.recordImageUUIDs {
//            let image = try await imageDataSource.load(imageID: recordImageUUID, category: .record(id: record.id))
//            resultImages.append(image)
//        }
        
        resultImages = try await withThrowingTaskGroup(
            of: (index: Int, image: UIImage).self,
            returning: [UIImage].self,
            body: { group in
                
                for recordImageData in record.recordImageUUIDs.enumerated() {
                    group.addTask {
                        let index = recordImageData.offset
                        let image =  try await self.imageDataSource.load(imageID: recordImageData.element, category: .record(id: record.id))
                        return (index: index, image: image)
                    }
                }
                
                var sortedImageData: [(index: Int, image: UIImage)] = []
                for try await resultImageData in group {
                    sortedImageData.append(resultImageData)
                }
                return sortedImageData
                    .sorted { $0.index < $1.index }
                    .map(\.image)
            }
        )
        
        return resultImages
    }
    
}
