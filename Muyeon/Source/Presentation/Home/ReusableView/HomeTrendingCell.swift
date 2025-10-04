//
//  HomeTrendingCell.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

import Kingfisher
import SnapKit

class HomeTrendingCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let placeNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6.withAlphaComponent(0.3)
        contentView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        
        placeNameLabel.font = .systemFont(ofSize: 11)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(placeNameLabel)
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(1.333)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
        }
        placeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func configure(with uiModel: HomeUIModel) {
        guard case .trending(let model) = uiModel else { return }
        let targetSize = imageView.bounds.size.applying(.init(scaleX: 0.8, y: 0.8))
        let processor = DownsamplingImageProcessor(size: targetSize)
        imageView.kf.setImage(
            with: URL(string: model.posterURL),
            options: [.processor(processor), .scaleFactor(UIScreen.main.scale),]
        )
        titleLabel.text = model.name
        placeNameLabel.text = model.performingPlaceName
    }
    
}
