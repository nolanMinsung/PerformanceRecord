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
    private let slashImageView = UIImageView(image: .init(systemName: "line.diagonal"))
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
        
        slashImageView.tintColor = .lightGray
        
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
        iconBackgroundView.addSubview(slashImageView)
    }
    
    func setupLayoutConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        iconBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        slashImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(30)
        }
    }
    
    func configure(icon: UIImage?, text: String, isAvailable: Bool) {
        iconImageView.image = icon
        label.text = text

        if isAvailable {
            iconBackgroundView.backgroundColor = UIColor(red: 0.82, green: 0.97, blue: 0.85, alpha: 1.00) // light green
            iconImageView.tintColor = .systemGreen
            slashImageView.isHidden = true
            label.textColor = .label
        } else {
            iconBackgroundView.backgroundColor = .systemGray5
            iconImageView.tintColor = .systemGray2
            slashImageView.isHidden = false
            label.textColor = .secondaryLabel
        }
    }
}
