//
//  HomeTopTenHeaderView.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit
import SnapKit

class HomeTopTenHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.text = "TOP 10"
        dateLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        dateLabel.text = Date.now.addingDay(-2).formatted(date: .abbreviated, time: .omitted)
        
        addSubview(titleLabel)
        addSubview(dateLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
