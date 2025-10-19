//
//  RecordMainCollectionView.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/19/25.
//

import UIKit

final class RecordMainCollectionView: UICollectionView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is InfoCardView {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
}
