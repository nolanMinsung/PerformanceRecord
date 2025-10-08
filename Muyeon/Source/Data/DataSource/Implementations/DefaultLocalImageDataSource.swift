//
//  LocalImageDataSource.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import UIKit
import ImageIO
import UniformTypeIdentifiers

enum DefaultImageDataSourceError: LocalizedError {
    
    enum Reason: LocalizedError {
        case documentDirectoryNotFound
        case failedConvertingToImageFromFile
        case imageFileNotFound
        case imageFolderNotFound
        case fileURLIsNotFolder
        
        var errorDescription: String? {
            switch self {
            case .documentDirectoryNotFound:
                "document directory를 찾을 수 없습니다."
            case .failedConvertingToImageFromFile:
                "file을 이미지 파일로 변환하는 데 실패했습니다."
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
        
        // 카테고리에 맞는 폴더 URL 생성
        let folderURL = documentsURL.appendingPathComponent(category.subpath)
        
        // 폴더가 없으면 생성
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        // 최종 파일 URL 결정 후 저장
        let fileURL = folderURL.appendingPathComponent(imageID).appendingPathExtension(imageData.type.preferredFilenameExtension ?? "jpeg")
        try imageData.data.write(to: fileURL)
        print("이미지 저장 성공: \(fileURL)")
    }
    
    func load(imageID: String, category: ImageCategory) async throws -> UIImage {
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
                .appendingPathComponent(imageID)
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
    
    func delete(imageID: String, category: ImageCategory) async throws {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DefaultImageDataSourceError.imageDeletingError(reason: .documentDirectoryNotFound)
        }
        
        // 저장된 이미지의 전체 경로 생성
        let fileURL = documentsURL.appendingPathComponent(category.subpath)
            .appendingPathComponent(imageID)
            .appendingPathExtension("jpeg")
        
        // 해당 경로에 파일이 실제로 존재하는지 확인
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw DefaultImageDataSourceError.imageDeletingError(reason: .imageFileNotFound)
        }
        
        try fileManager.removeItem(at: fileURL)
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

extension DefaultLocalImageDataSource {
    
    /// `data`가 이미지 파일이 맞는지 확인 후, 맞으면 이미지 파일 확장자를 반환. 이미지 파일이 아닐 경우 `nil` 반환
    private func imageFileExtension(from data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source),
              let utType = UTType(type as String)
        else {
            return nil
        }
        return utType.preferredFilenameExtension
    }
    
}
