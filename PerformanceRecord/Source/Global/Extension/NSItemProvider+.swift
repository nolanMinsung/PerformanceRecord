//
//  NSItemProvider+.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit
import UniformTypeIdentifiers

extension NSItemProvider {
    
    enum NSItemProviderError: LocalizedError {
        case loadingDataFromNSProviderFaild
        case loadedFromNSProviderButDataNotFound
        case loadImageFailed
    }
    
    func loadDataRepresentation(for contentType: UTType) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            if #available(iOS 16, *) {
                let _ = loadDataRepresentation(for: contentType) { data, error in
                    switch (data, error) {
                    case (_, .some(let error)):
                        // 에러 발생
                        continuation.resume(throwing: error)
                    case (.some(let data), .none):
                        continuation.resume(returning: data)
                    case (.none, .none):
                        // 에러는 없는데 데이터도 없는 이상한 상황
                        continuation.resume(throwing: NSItemProviderError.loadedFromNSProviderButDataNotFound)
                    }
                }
            } else {
                let _ = loadDataRepresentation(forTypeIdentifier: contentType.identifier) { data, error in
                    switch (data, error) {
                    case (_, .some(let error)):
                        // 에러 발생
                        continuation.resume(throwing: error)
                    case (.some(let data), .none):
                        continuation.resume(returning: data)
                    case (.none, .none):
                        // 에러는 없는데 데이터도 없는 이상한 상황
                        continuation.resume(throwing: NSItemProviderError.loadedFromNSProviderButDataNotFound)
                    }
                }
            }
        }
    }
    
    func loadImage() async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            self.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    continuation.resume(returning: image)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSItemProviderError.loadImageFailed)
                }
            }
        }
        
    }

}
