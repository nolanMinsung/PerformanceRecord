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
    private let performingPeriodLabel = UILabel()
    private let textStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        
        placeNameLabel.font = .systemFont(ofSize: 11)
        
        performingPeriodLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        performingPeriodLabel.numberOfLines = 2
        
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading
        textStackView.distribution = .fill
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(placeNameLabel)
        textStackView.addArrangedSubview(performingPeriodLabel)
        
        contentView.addSubview(imageView)
        contentView.addSubview(textStackView)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(1.333)
        }
        
        textStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
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
        guard case .trending(let boxOfficeItem) = uiModel else { return }
        let targetSize = imageView.bounds.size.applying(.init(scaleX: 0.8, y: 0.8))
        let processor = DownsamplingImageProcessor(size: targetSize)
        imageView.kf.setImage(
            with: URL(string: boxOfficeItem.posterURL),
            options: [.processor(processor), .scaleFactor(UIScreen.main.scale),]
        )
        titleLabel.text = boxOfficeItem.name
        placeNameLabel.text = boxOfficeItem.performingPlaceName
        performingPeriodLabel.text = boxOfficeItem.performPeriod.replacingOccurrences(of: "~", with: "~\n")
    }
    
}
