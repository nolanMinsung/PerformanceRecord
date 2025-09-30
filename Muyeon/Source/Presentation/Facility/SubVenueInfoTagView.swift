//
//  SubVenueInfoTagView.swift
//  Muyeon
//
//  Created by 김민성 on 9/30/25.
//

import UIKit

// MARK: - SubVenueInfoTagView (재사용 가능한 태그 뷰)
/// 아이콘, 텍스트, 배경색을 가지는 재사용 가능한 태그 컴포넌트입니다.
class SubVenueInfoTagView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // SF Symbol의 기본 색상을 지정합니다.
        imageView.tintColor = UIColor.darkGray
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        return stackView
    }()

    init(icon: UIImage?, text: String, color: UIColor) {
        super.init(frame: .zero)
        
        backgroundColor = color.withAlphaComponent(0.1)
        layer.cornerRadius = 12
        clipsToBounds = true
        
        iconImageView.image = icon
        iconImageView.tintColor = color
        textLabel.text = text
        textLabel.textColor = color
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        stackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
    }
}
