//
//  RemoteImageDataSource.swift
//  Muyeon
//
//  Created by 김민성 on 10/5/25.
//

import Foundation

protocol RemoteImageDataSource {
    func download(from url: String) async throws -> Data
}
