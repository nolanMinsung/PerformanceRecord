//
//  PerformanceSelectionCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class PerformanceSelectionCell: UICollectionViewCell {
    static let identifier = "PerformanceSelectionCell"
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let venueLabel = UILabel()
    private let genreTagLabelContainer = UIView()
    private let genreTagLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            containerView.layer.borderColor = isSelected ? UIColor.Main.primary.cgColor : UIColor.systemGray5.cgColor
            containerView.backgroundColor = isSelected ? .Main.primary.withAlphaComponent(0.05) : .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // UI 컴포넌트 속성 설정
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.numberOfLines = 0
        venueLabel.font = .systemFont(ofSize: 14)
        venueLabel.textColor = .secondaryLabel
        venueLabel.numberOfLines = 2
        
        genreTagLabelContainer.backgroundColor = .Main.primary.withAlphaComponent(0.1)
        genreTagLabelContainer.layer.cornerRadius = 6
        genreTagLabelContainer.layer.masksToBounds = true
        genreTagLabel.font = .systemFont(ofSize: 12, weight: .medium)
        genreTagLabel.textColor = .Main.primary
        genreTagLabel.textAlignment = .center
        
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.clipsToBounds = true
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, venueLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 4
        infoStack.distribution = .fill
        
        genreTagLabelContainer.addSubview(genreTagLabel)
        
        contentView.addSubview(containerView)
        containerView.addSubview(infoStack)
        containerView.addSubview(genreTagLabelContainer)
        
        containerView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(6)
            make.horizontalEdges.equalToSuperview()
        }
        
        infoStack.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.contentCompressionResistanceVerticalPriority = 900
        titleLabel.snp.contentCompressionResistanceHorizontalPriority = 900
        titleLabel.snp.contentHuggingVerticalPriority = 1000
        venueLabel.snp.contentCompressionResistanceVerticalPriority = 1000
        venueLabel.snp.contentHuggingVerticalPriority = 1000
        
        genreTagLabelContainer.snp.contentHuggingHorizontalPriority = 800
        genreTagLabel.snp.contentCompressionResistanceHorizontalPriority = 1000
        genreTagLabelContainer.snp.contentCompressionResistanceHorizontalPriority = 1000
        genreTagLabelContainer.snp.makeConstraints { make in
            make.centerY.equalTo(infoStack)
            make.leading.equalTo(infoStack.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }
        
        genreTagLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
    }

    func configure(with performance: Performance) {
        titleLabel.text = performance.name
        venueLabel.text = performance.facilityFullName
        genreTagLabel.text = performance.genre.description
    }
    
}
