//
//  FileManagerImageStoreService.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import UIKit

import Kingfisher
import RealmSwift

final class FileManagerImageStoreService {
    
    static func downloadAndSaveImage(from urlString: String, folderName: String) async throws -> String? {
        guard let url = URL(string: urlString) else { return nil }
        
        let retrieveResult = try await KingfisherManager.shared.retrieveImage(with: url).image
        guard let imageData = retrieveResult.jpegData(compressionQuality: 0.8) else { return nil }
        
        let fileUUID = UUID().uuidString
        let fileManager = FileManager.default
        
        // 앱 Documents 디렉토리 내에 커스텀 폴더(performanceID)를 생성
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document directory not found."])
        }
        
        let folderURL = documentsURL.appendingPathComponent(folderName)
        // 폴더가 없으면 생성
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileURL = folderURL.appendingPathComponent(fileUUID).appendingPathExtension(for: .jpeg)
        
        // FileManager에 저장
        try imageData.write(to: fileURL)
        print("이미지 저장 성공: \(fileURL)")
        // 로컬 DB에 저장한 UUID 반환
        return fileUUID
    }
    
}
