//
//  HomeTopTenCell.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

import Kingfisher
import SnapKit

class HomeTopTenCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 23
        contentView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.backgroundColor = .systemBackground.withAlphaComponent(0.7)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with uiModel: HomeUIModel) {
        switch uiModel {
        case .topTen(let model):
            imageView.kf.setImage(with: URL(string: model.posterURL))
            titleLabel.text = model.name
        case .trending(let model):
            imageView.kf.setImage(with: URL(string: model.posterURL))
            titleLabel.text = model.name
        }
    }
    
}
