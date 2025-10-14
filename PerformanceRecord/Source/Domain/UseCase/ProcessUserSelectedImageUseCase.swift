//
//  ProcessUserSelectedImageUseCase.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/13/25.
//

protocol ProcessUserSelectedImageUseCase {
    func execute(with providers: [any ImageDataProvider]) async throws -> [ImageDataForSaving]
}


final class DefaultProcessUserSelectedImageUseCase: ProcessUserSelectedImageUseCase {
    
    func execute(with providers: [any ImageDataProvider]) async throws -> [ImageDataForSaving] {
        return try await withThrowingTaskGroup(of: (index: Int, imageData: ImageDataForSaving).self) { group in
            for item in providers.enumerated() {
                group.addTask {
                    return (index: item.offset, imageData: try await item.element.load())
                }
            }
            var sortedItemResultArray: [(index: Int, imageData: ImageDataForSaving)] = []
            for try await result in group {
                sortedItemResultArray.append(result)
            }
            let sortedImage = sortedItemResultArray
                .sorted(by: { $0.index < $1.index })
                .map(\.imageData)
            return sortedImage
        }
    }
    
}
