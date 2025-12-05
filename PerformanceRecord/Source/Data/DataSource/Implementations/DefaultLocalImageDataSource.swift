//
//  LocalImageDataSource.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import UIKit
import ImageIO // UIKit에 이미 내장. 명시적 표현을 위해 작성
import UniformTypeIdentifiers

enum DefaultImageDataSourceError: LocalizedError {
    
    enum Reason: LocalizedError {
        case documentDirectoryNotFound
        case failedConvertingToImageFromFile
        case failedConvertingToThumbnailFromFile
        case imageFileNotFound
        case imageFolderNotFound
        case fileURLIsNotFolder
        
        var errorDescription: String? {
            switch self {
            case .documentDirectoryNotFound:
                "document directory를 찾을 수 없습니다."
            case .failedConvertingToImageFromFile:
                "file을 이미지 파일로 변환하는 데 실패했습니다."
            case .failedConvertingToThumbnailFromFile:
                "file을 썸네일 이미지 파일로 변환하는 데 실패했습니다."
            case .imageFileNotFound:
                "경로에 이미지 파일이 존재하지 않습니다."
            case .imageFolderNotFound:
                "경로에 이미지 폴더가 존재하지 않습니다."
            case .fileURLIsNotFolder:
                "지정된 경로가 폴더가 아닙니다ㅏ."
            }
        }
    }
    
    case imageSavingError(reason: Reason)
    case imageLoadingError(reason: Reason)
    case imageDeletingError(reason: Reason)
    
    var errorDescription: String? {
        switch self {
        case .imageSavingError(let reason):
            return "이미지 저장 실패: \(reason.localizedDescription)"
        case .imageLoadingError(let reason):
            return "이미지 불러오기 실패: \(reason.localizedDescription)"
        case .imageDeletingError(let reason):
            return "이미지 삭제 실패: \(reason.localizedDescription)"
        }
    }
}

actor DefaultLocalImageDataSource: LocalImageDataSource {
    
    static let shared = DefaultLocalImageDataSource()
    private init() { }
    
    func save(imageData: ImageDataForSaving, imageID: String, category: ImageCategory) async throws {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DefaultImageDataSourceError.imageSavingError(reason: .documentDirectoryNotFound)
        }
        
        guard let thumbnailData = createThumbnailDataWithImageIO(from: imageData.data, maxPixelSize: 300) else {
            throw DefaultImageDataSourceError.imageSavingError(reason: .failedConvertingToThumbnailFromFile)
        }
        
        // 카테고리에 맞는 폴더 URL 생성
        let folderURL = documentsURL.appendingPathComponent(category.subpath)
        
        // 폴더가 없으면 생성
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        // 최종 파일 URL 결정 후 저장
        let fileURL = folderURL
            .appendingPathComponent(imageID)
            .appendingPathExtension(imageData.type.preferredFilenameExtension ?? "jpeg")
        let thumbnailFileURL = folderURL
            .appendingPathComponent("\(imageID)_thumbnail")
            .appendingPathExtension(imageData.type.preferredFilenameExtension ?? "jpeg")
        
        try imageData.data.write(to: fileURL)
        try thumbnailData.write(to: thumbnailFileURL)
        print("이미지 저장 성공: \(fileURL)")
    }
    
    func load(imageID: String, category: ImageCategory) async throws -> UIImage {
        return try await loadImageFile(fileName: imageID, category: category)
    }
    
    func loadThumbnail(imageID: String, category: ImageCategory) async throws -> UIImage {
        return try await loadImageFile(fileName: "\(imageID)_thumbnail", category: category)
    }
    
    func delete(imageID: String, category: ImageCategory) async throws {
        // 썸네일 삭제
        try await deleteImageFile(fileName: "\(imageID)_thumbnail", category: category)
        // 이미지 삭제
        try await deleteImageFile(fileName: imageID, category: category)
    }
    
    func deleteAllImages(in imageCategory: ImageCategory) async throws {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DefaultImageDataSourceError.imageDeletingError(reason: .documentDirectoryNotFound)
        }
        
        // 이미지 폴더의 전체 경로 생성
        let folderURL = documentsURL.appendingPathComponent(imageCategory.subpath)
        
        guard documentsURL.isFileURL else {
            throw DefaultImageDataSourceError.imageDeletingError(reason: .fileURLIsNotFolder)
        }
        
        // 해당 경로에 파일이 실제로 존재하는지 확인
        guard fileManager.fileExists(atPath: folderURL.path) else {
            throw DefaultImageDataSourceError.imageDeletingError(reason: .imageFileNotFound)
        }
        // Performance의 이미지가 모두 들어있는 폴더 자체를 삭제
        try fileManager.removeItem(at: folderURL)
    }
    
}

private extension DefaultLocalImageDataSource {
    
    func loadImageFile(fileName: String, category: ImageCategory) async throws -> UIImage {
        let possibleImageType: [UTType] = [.jpeg, .png, .heic, .heif, .gif, .tiff, .webP, .bmp]
        let possibleExtensions: [String] = possibleImageType.compactMap { $0.preferredFilenameExtension } + ["jpg"]
        
        let fileManager = FileManager.default
        
        // Documents 디렉토리 경로 가져오기
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DefaultImageDataSourceError.imageLoadingError(reason: .documentDirectoryNotFound)
        }
        
        // 예상되는 이미지 확장자를 순회하며 파일의 확장자 유추
        for extensionString in possibleExtensions {
            // 저장된 이미지의 전체 경로 생성
            let fileURL = documentsURL.appendingPathComponent(category.subpath)
                .appendingPathComponent(fileName)
                .appendingPathExtension(extensionString)
            
            // 해당 경로에 파일이 실제로 존재하는지 확인
            if fileManager.fileExists(atPath: fileURL.path) {
                // 경로로부터 UIImage 객체 생성
                guard let image = UIImage(contentsOfFile: fileURL.path) else {
                    // 파일은 있지만, 이미지로 변환이 실패한 경우
                    throw DefaultImageDataSourceError.imageLoadingError(reason: .failedConvertingToImageFromFile)
                }
                return image
            }
        }
        throw DefaultImageDataSourceError.imageLoadingError(reason: .imageFileNotFound)
    }
    
    func deleteImageFile(fileName: String, category: ImageCategory) async throws {
        let possibleImageType: [UTType] = [.jpeg, .png, .heic, .heif, .gif, .tiff, .webP, .bmp]
        let possibleExtensions: [String] = possibleImageType.compactMap { $0.preferredFilenameExtension } + ["jpg"]
        
        let fileManager = FileManager.default
        
        // Documents 디렉토리 경로 가져오기
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DefaultImageDataSourceError.imageLoadingError(reason: .documentDirectoryNotFound)
        }
        
        // 예상되는 이미지 확장자를 순회하며 파일의 확장자 유추
        for extensionString in possibleExtensions {
            // 저장된 이미지의 전체 경로 생성
            let fileURLToDelete = documentsURL.appendingPathComponent(category.subpath)
                .appendingPathComponent(fileName)
                .appendingPathExtension(extensionString)
            
            // 해당 경로에 파일이 실제로 존재하는지 확인
            if fileManager.fileExists(atPath: fileURLToDelete.path) {
                try fileManager.removeItem(at: fileURLToDelete)
                print("단일 이미지(및 썸네일) 삭제 성공: \(fileURLToDelete)")
            }
        }
    }
    
    /// `data`가 이미지 파일이 맞는지 확인 후, 맞으면 이미지 파일 확장자를 반환. 이미지 파일이 아닐 경우 `nil` 반환
    func imageFileExtension(from data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source),
              let utType = UTType(type as String)
        else {
            return nil
        }
        return utType.preferredFilenameExtension
    }
    
    func createThumbnailDataWithImageIO(from imageData: Data, maxPixelSize: Int) -> Data? {
        // 썸네일 생성 옵션 설정
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true, // 썸네일이 없는 경우에만 생성
            kCGImageSourceCreateThumbnailWithTransform: true,     // 이미지 방향(orientation)을 썸네일에 반영
            kCGImageSourceShouldCacheImmediately: true,           // 생성된 썸네일을 즉시 디코딩(캐시)
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize     // 썸네일의 가로/세로 중 더 긴 쪽의 최대 크기
        ]

        // CGImageSource 생성
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        // 옵션을 사용하여 썸네일 CGImage 생성
        guard let thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }

        // CGImage -> UIImage -> Data 변환
        // 이미지 썸네일 용량 작아서 메모리 부담 적음.
        let uiImage = UIImage(cgImage: thumbnailImage)
        return uiImage.jpegData(compressionQuality: 1.0)
    }
    
    #if DEBUG
    /// 원본 이미지 데이터를 UIImage로 완전히 로드한 후, `UIGraphicsImageRenderer`를 사용해 썸네일 `Data`를 생성.
    /// `ImageIO` 사용 대비 얼마나 비효율적인지 테스트하기 위한 함수. (실제 사용 X)
    func createThumbnailDataWithoutImageIO(from imageData: Data, maxPixelSize: Int) -> Data? {
        
        // 원본 이미지 데이터를 UIImage로 로드
        guard let originalImage = UIImage(data: imageData) else {
            return nil
        }

        let originalSize = originalImage.size
        
        // 최대 픽셀 크기에 맞게 새로운 크기(CGSize) 계산
        let targetWidth: CGFloat
        let targetHeight: CGFloat
        
        // 원본 비율 유지 (Aspect Fit)
        if originalSize.width > originalSize.height {
            // 가로가 더 길면, 가로를 maxPixelSize에 맞추기.
            targetWidth = CGFloat(maxPixelSize)
            targetHeight = originalSize.height * (targetWidth / originalSize.width)
        } else {
            // 세로가 더 길거나 같으면, 세로를 maxPixelSize에 맞추기.
            targetHeight = CGFloat(maxPixelSize)
            targetWidth = originalSize.width * (targetHeight / originalSize.height)
        }
        
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        
        // UIGraphicsImageRenderer사용 - 이미지 리사이징 및 렌더링
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let thumbnailImage = renderer.image { context in
            // 이미 메모리에 로드된 원본 이미지를 새로운 크기에 맞게 그리기
            originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        // UIImage -> Data 변환 후 반환
        // (압축 품질을 ImageIO 함수와 동일하게 1.0으로 설정)
        return thumbnailImage.jpegData(compressionQuality: 1.0)
    }
    #endif
}
