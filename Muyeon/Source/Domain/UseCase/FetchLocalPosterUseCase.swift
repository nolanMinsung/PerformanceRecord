//
//  FetchLocalPosterUseCase.swift
//  Muyeon
//
//  Created by 김민성 on 10/8/25.
//

import UIKit

protocol FetchLocalPosterUseCase {
    func execute(performance: Performance) async throws -> UIImage
}


final class DefaultFetchLocalPosterUseCase: FetchLocalPosterUseCase {
    
    enum DefaultFetchLocalPosterUseCaseError: LocalizedError {
        case posterImageNotFound
    }
    
    let imageRepository: any ImageRepository
    
    init(
        imageRepository: any ImageRepository
    ) {
        self.imageRepository = imageRepository
    }
    
    func execute(performance: Performance) async throws -> UIImage {
        guard let posterImageID = performance.posterImageID else {
            throw DefaultFetchLocalPosterUseCaseError.posterImageNotFound
        }
        return try await imageRepository.loadImage(with: posterImageID, in: .performance(id: performance.id))
    }
    
}
