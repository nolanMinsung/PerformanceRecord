//
//  AmenityIconView.swift
//  Muyeon
//
//  Created by 김민성 on 9/30/25.
//

import UIKit

import SnapKit

/// 공연시설의 개별 편의시설 아이콘과 라벨을 표시하는 뷰
class AmenityIconView: UIView, BaseViewSettings {
    
    private let iconImageView =  UIImageView()
    private let iconBackgroundView =  UIView()
    private let label =  UILabel()
    private let stackView =  UIStackView()
    
    init(icon: UIImage?, text: String, isAvailable: Bool) {
        super.init(frame: .zero)
        
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
        configure(icon: icon, text: text, isAvailable: isAvailable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUIProperties() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        
        iconBackgroundView.layer.cornerRadius = 8
        
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        
        stackView.addArrangedSubview(iconBackgroundView)
        stackView.addArrangedSubview(label)
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
    }
    
    func setupHierarchy() {
        addSubview(stackView)
        iconBackgroundView.addSubview(iconImageView)
    }
    
    func setupLayoutConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        iconBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalTo(iconBackgroundView)
            make.size.equalTo(24)
        }
    }
    
    func configure(icon: UIImage?, text: String, isAvailable: Bool) {
        iconImageView.image = icon
        label.text = text

        if isAvailable {
            iconBackgroundView.backgroundColor = UIColor(red: 0.82, green: 0.97, blue: 0.85, alpha: 1.00) // light green
            iconImageView.tintColor = .systemGreen
            label.textColor = .label
        } else {
            iconBackgroundView.backgroundColor = .systemGray5
            iconImageView.tintColor = .systemGray2
            label.textColor = .secondaryLabel
        }
    }
}
