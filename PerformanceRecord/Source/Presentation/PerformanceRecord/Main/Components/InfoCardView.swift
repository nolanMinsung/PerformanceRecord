//
//  InfoCardView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import SnapKit

// MARK: - 정보 카드 뷰 (최근/최다 관람 등)
class InfoCardView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
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
        label.numberOfLines = 0
        return label
    }()
    
    private let tagLabelContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
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
        
        tagLabelContainer.addSubview(tagLabel)
        let contentStack = UIStackView(arrangedSubviews: [mainContentLabel, tagLabelContainer])
        contentStack.axis = .horizontal
        contentStack.spacing = 8
        contentStack.alignment = .center
        
        let mainVStack = UIStackView(arrangedSubviews: [headerStack, contentStack, subContentLabel])
        mainVStack.axis = .vertical
        mainVStack.spacing = 10
        mainVStack.alignment = .leading
        
        addSubview(mainVStack)
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(6)
        }
        
        mainVStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    func configure(mainText: String, tagText: String?, tagColor: UIColor?, subText: String) {
        mainContentLabel.text = mainText
        subContentLabel.text = subText
        
        if let tagText = tagText, let tagColor = tagColor {
            tagLabel.text = tagText
            tagLabelContainer.backgroundColor = tagColor
            tagLabelContainer.isHidden = false
        } else {
            tagLabel.isHidden = true
        }
    }
}
