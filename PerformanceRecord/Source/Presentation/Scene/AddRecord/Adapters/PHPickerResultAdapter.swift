//
//  PHPickerResultAdapter.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/14/25.
//

import PhotosUI


enum PHPickerImageDataProviderError: LocalizedError {
    case itemProviderInvalidTypeIdentifier
    case unsupportedImageExtension
}


final class PHPickerResultAdapter: ImageDataProvider {
    
    private let phPickerResult: PHPickerResult
    
    init(phPickerResult: PHPickerResult) {
        self.phPickerResult = phPickerResult
    }
    
    func load() async throws -> ImageDataForSaving {
        let itemProvider = phPickerResult.itemProvider
        guard itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
            throw PHPickerImageDataProviderError.itemProviderInvalidTypeIdentifier
        }
        
        let data = try await self.prepareImageData(from: itemProvider)
        return data
    }
    
    private func prepareImageData(from provider: NSItemProvider) async throws -> ImageDataForSaving {
        let supportedTypes: [UTType] = [.heic, .jpeg, .png, .tiff, .gif, .webP, .bmp]
        guard let supportedType = supportedTypes.first(
            where: { type in provider.hasItemConformingToTypeIdentifier(type.identifier)}
        ) else {
            throw PHPickerImageDataProviderError.unsupportedImageExtension
        }
        let data = try await provider.loadDataRepresentation(for: supportedType)
        return ImageDataForSaving(data: data, type: supportedType)
    }
    
}

