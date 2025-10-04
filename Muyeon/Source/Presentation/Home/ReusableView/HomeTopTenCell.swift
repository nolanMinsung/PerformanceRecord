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
    
    let imageView = UIImageView()
    private let backGradientView = BottomGradientView(color: .label)
    private let rankNumLabel = UILabel()
    private let titleLabel = UILabel()
    private let datePeriodLabel = UILabel()
    private let placeNameLabel = UILabel()
    private lazy var infoStackView = UIStackView(arrangedSubviews: [titleLabel, datePeriodLabel, placeNameLabel])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 23
        contentView.clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.label.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = .init(x: 0.5, y: 1)
        gradientLayer.endPoint = .init(x: 0.5, y: 0)
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        
        rankNumLabel.font = .systemFont(ofSize: 70, weight: .heavy)
        rankNumLabel.textColor = .systemBackground
        
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .systemBackground
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        datePeriodLabel.numberOfLines = 2
        datePeriodLabel.textColor = .systemBackground
        datePeriodLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        placeNameLabel.numberOfLines = 1
        placeNameLabel.textColor = .systemBackground
        placeNameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        infoStackView.axis = .vertical
        infoStackView.spacing = 5
        infoStackView.alignment = .leading
        infoStackView.distribution = .fill
        
        contentView.addSubview(imageView)
        contentView.addSubview(backGradientView)
        contentView.addSubview(rankNumLabel)
        contentView.addSubview(infoStackView)
        
        backGradientView.snp.makeConstraints { make in
            make.top.equalTo(rankNumLabel.snp.top).offset(-40)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        rankNumLabel.snp.contentCompressionResistanceHorizontalPriority = 1000
        rankNumLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(10)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        infoStackView.snp.makeConstraints { make in
            make.centerY.equalTo(rankNumLabel)
            make.leading.equalTo(rankNumLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with uiModel: HomeUIModel) {
        guard case .topTen(let model) = uiModel else {
            return
        }
        imageView.kf.setImage(with: URL(string: model.posterURL))
        rankNumLabel.text = "\(model.rank)"
        titleLabel.text = model.name
        datePeriodLabel.text = model.performPeriod
        placeNameLabel.text = model.performingPlaceName
    }
    
}
