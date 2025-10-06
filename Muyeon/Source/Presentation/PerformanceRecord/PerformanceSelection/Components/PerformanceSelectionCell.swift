//
//  PerformanceSelectionCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class PerformanceSelectionCell: UITableViewCell {
    static let identifier = "PerformanceSelectionCell"

    private let titleLabel = UILabel()
    private let venueLabel = UILabel()
    private let genreTagLabelContainer = UIView()
    private let genreTagLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // UI 컴포넌트 속성 설정
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        venueLabel.font = .systemFont(ofSize: 14)
        venueLabel.textColor = .secondaryLabel
        
        genreTagLabelContainer.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        genreTagLabelContainer.layer.cornerRadius = 6
        genreTagLabelContainer.layer.masksToBounds = true
        genreTagLabel.font = .systemFont(ofSize: 12, weight: .medium)
        genreTagLabel.textColor = .systemBlue
        genreTagLabel.textAlignment = .center
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, venueLabel])
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 4
        
        genreTagLabelContainer.addSubview(genreTagLabel)
        let mainStack = UIStackView(arrangedSubviews: [infoStack, genreTagLabelContainer])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        
        contentView.addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        genreTagLabelContainer.snp.contentHuggingHorizontalPriority = 800
        genreTagLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
    }

    func configure(with performance: Performance) {
        titleLabel.text = performance.name
        venueLabel.text = "📍 \(performance.facilityFullName)"
        genreTagLabel.text = performance.genre.description
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.systemGray5.cgColor
        contentView.backgroundColor = selected ? .systemBlue.withAlphaComponent(0.05) : .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 셀 사이의 간격
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
    }
}
