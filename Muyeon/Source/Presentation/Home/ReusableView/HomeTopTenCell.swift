//
//  HomeTopTenCell.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

class HomeTopTenCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 23
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
