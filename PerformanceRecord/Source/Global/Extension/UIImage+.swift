//
//  UIImage+.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import UIKit

extension UIImage {
    
    func resized(ratio: CGFloat) -> UIImage {
        let targetSize = self.size.applying(.init(scaleX: ratio, y: ratio))
        return self.resized(targetSize: targetSize)
    }
    
    func resized(targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat(for: self.traitCollection)
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { context in
            let rect = CGRect(origin: .zero, size: targetSize)
            self.draw(in: rect)
        }
        return resizedImage
        
//        let rect = CGRect(origin: .zero, size: targetSize)
//        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
//        self.draw(in: rect)
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return resizedImage
    }
    
}

