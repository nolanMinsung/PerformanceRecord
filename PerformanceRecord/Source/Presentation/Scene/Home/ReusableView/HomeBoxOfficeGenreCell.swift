//
//  HomeBoxOfficeGenreCell.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

class HomeBoxOfficeGenreCell: UICollectionViewCell, ViewShrinkable {
    
    private let bubbleBackground = UIImageView(image: .bubble24Blue)
    private let genreNameLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                shrink(duration: 1.0, scale: 0.9, isBubble: true)
            } else {
                restore(duration: 1.0, isBubble: true)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet { setSelected(isSelected) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20 // 셀 높이는 40으로 고정되어있음.
        contentView.clipsToBounds = true
        contentView.addSubview(bubbleBackground)
        contentView.addSubview(genreNameLabel)
        
        bubbleBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        genreNameLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(15)
        }
        self.setSelected(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ isSelected: Bool) {
        let fontWeight: UIFont.Weight = isSelected ? .bold : .regular
        genreNameLabel.font = .systemFont(ofSize: 15, weight:  fontWeight)
        genreNameLabel.textColor = isSelected ? .Main.primary : .gray
        contentView.backgroundColor = isSelected ? .Main.primary.withAlphaComponent(0.07) : .clear
        
    }
    
    func configure(with model: HomeUIModel) {
        guard case .genre(let model) = model else {
            assertionFailure()
            return
        }
        genreNameLabel.text = model.description
    }
    
}
