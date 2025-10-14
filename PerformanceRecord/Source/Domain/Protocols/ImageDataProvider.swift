//
//  ImageDataProvider.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/13/25.
//

import UniformTypeIdentifiers

protocol ImageDataProvider {
    func load() async throws -> ImageDataForSaving
}
