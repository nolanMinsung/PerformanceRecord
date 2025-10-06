//
//  InfoCardView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

// MARK: - 정보 카드 뷰 (최근/최다 관람 등)
class InfoCardView: UIView {
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let mainContentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let subContentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    init(iconName: String, title: String) {
        super.init(frame: .zero)
        self.iconImageView.image = UIImage(systemName: iconName)
        self.titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 16
        
        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        
        let contentStack = UIStackView(arrangedSubviews: [mainContentLabel, tagLabel])
        contentStack.axis = .horizontal
        contentStack.spacing = 8
        contentStack.alignment = .center
        
        let mainVStack = UIStackView(arrangedSubviews: [headerStack, contentStack, subContentLabel])
        mainVStack.axis = .vertical
        mainVStack.spacing = 10
        mainVStack.alignment = .leading
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainVStack)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            tagLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            tagLabel.heightAnchor.constraint(equalToConstant: 22),
            
            mainVStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainVStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainVStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainVStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }
    
    func configure(mainText: String, tagText: String?, tagColor: UIColor?, subText: String) {
        mainContentLabel.text = mainText
        subContentLabel.text = subText
        
        if let tagText = tagText, let tagColor = tagColor {
            tagLabel.text = tagText
            tagLabel.backgroundColor = tagColor
            tagLabel.isHidden = false
        } else {
            tagLabel.isHidden = true
        }
    }
}
