//
//  UICollectionReusableView+.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

extension UICollectionReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}
