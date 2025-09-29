//
//  HomeTrendingHeaderView.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

class HomeTrendingHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray6
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        titleLabel.text = "지금 뜨는 공연"
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
