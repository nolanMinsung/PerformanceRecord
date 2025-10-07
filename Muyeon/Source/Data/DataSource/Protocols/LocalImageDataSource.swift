//
//  LocalImageDataSource.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import UIKit

protocol LocalImageDataSource {
    func save(imageData: ImageDataForSaving, imageID: String, category: ImageCategory) async throws
    func load(imageID: String, category: ImageCategory) async throws -> UIImage
    func delete(imageID: String, category: ImageCategory) async throws
    func deleteAllImages(in imageCategory: ImageCategory) async throws
}
