//
//  ImageRepository.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import UIKit

protocol ImageRepository {
    /// Image URL 로부터 이미지 다운로드 및 저장 후 이미지 ID(파일 이름) 반환
    func saveImage(urlString: String, category: ImageCategory) async throws -> String
    
    /// Image Data 를 직접 저장 후 이미지 ID(파일 이름) 반환
    func saveImage(data: ImageDataForSaving, category: ImageCategory) async throws -> String
    
    /// 로컬 저장소에서 이미지를 가져와 반환
    func loadImage(with id: String, category: ImageCategory) async throws -> UIImage
    
    func deleteImage(with id: String, category: ImageCategory) async throws
    
    func deleteAllImages(of category: ImageCategory) async throws
}
