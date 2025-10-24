//
//  StatItemView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import SnapKit

class StatItemView: UIView {
    
    private let bubbleBackground: UIImageView = {
        let imageView = UIImageView(image: .bubble32Black)
        return imageView
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let mainValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let subValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainValueLabel, subValueLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    init(iconName: String, title: String) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = title
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.cornerRadius = 32
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, labelStackView])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .leading
        
        let hStack = UIStackView(arrangedSubviews: [iconImageView, vStack])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bubbleBackground)
        addSubview(hStack)
        
        bubbleBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func updateValue(mainText: String, subText: String) {
        mainValueLabel.text = mainText
        subValueLabel.text = subText
    }
    
}
