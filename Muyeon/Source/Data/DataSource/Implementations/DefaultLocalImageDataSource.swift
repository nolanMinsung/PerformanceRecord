//
//  LocalImageDataSource.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import UIKit
import ImageIO
import UniformTypeIdentifiers

final class DefaultLocalImageDataSource: LocalImageDataSource {
    
    func save(imageData: Data, imageID: String, category: ImageCategory) throws {
        guard let fileExtension = self.imageFileExtension(from: imageData) else {
            throw NSError(domain: "ImageSaveError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data."])
        }
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "ImageSaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found."])
        }
        
        // 카테고리에 맞는 폴더 URL 생성
        let folderURL = documentsURL.appendingPathComponent(category.subpath)
        
        // 폴더가 없으면 생성
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        // 최종 파일 URL 결정 후 저장
        let fileURL = folderURL.appendingPathComponent(imageID).appendingPathExtension(fileExtension)
        try imageData.write(to: fileURL)
        print("이미지 저장 성공: \(fileURL.path)")
    }
    
    func load(imageID: String, category: ImageCategory) throws -> UIImage {
        let fileManager = FileManager.default
        
        // Documents 디렉토리 경로 가져오기
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "ImageLoadingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found."])
        }
        
        // 저장된 이미지의 전체 경로 생성
        let fileURL = documentsURL.appendingPathComponent(category.subpath)
            .appendingPathComponent(imageID)
            .appendingPathExtension("jpeg")
        
        // 해당 경로에 파일이 실제로 존재하는지 확인
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw NSError(domain: "ImageNotFound", code: 2, userInfo: [NSLocalizedDescriptionKey: "Image File not found."])
        }
        
        // 경로로부터 UIImage 객체 생성
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            throw NSError(domain: "FaileToConvertToUIImage", code: 3, userInfo: [NSLocalizedDescriptionKey: "Converting File to UIImage Failed."])
        }
        return image
    }
    
    func delete(imageID: String, category: ImageCategory) throws {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "ImageLoadingError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found."])
        }
        
        // 저장된 이미지의 전체 경로 생성
        let fileURL = documentsURL.appendingPathComponent(category.subpath)
            .appendingPathComponent(imageID)
            .appendingPathExtension("jpeg")
        
        // 해당 경로에 파일이 실제로 존재하는지 확인
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw NSError(domain: "ImageNotFound", code: 2, userInfo: [NSLocalizedDescriptionKey: "Image File not found."])
        }
        
        try fileManager.removeItem(at: fileURL)
    }
    
    func deleteAllImages(of performance: Performance, category: ImageCategory) throws {
        let fileManager = FileManager.default
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "ImageLoadingError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found."])
        }
        
        // 이미지 폴더의 전체 경로 생성
        let folderURL = documentsURL.appendingPathComponent(category.subpath)
        
        guard documentsURL.isFileURL else {
            print("삭제를 시도하려는 경로가 folder가 아닙니다.")
            return
        }
        
        // 해당 경로에 파일이 실제로 존재하는지 확인
        guard fileManager.fileExists(atPath: folderURL.path) else {
            throw NSError(domain: "ImageFolderNotFound", code: 5, userInfo: [NSLocalizedDescriptionKey: "Image Folder not found."])
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
