//
//  HomeBoxOfficeGenreCell.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

class HomeBoxOfficeGenreCell: UICollectionViewCell, ViewShrinkable {
    
    private let genreNameLabel = UILabel()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                shrink(scale: 0.9)
            } else {
                restore()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet { setSelected(isSelected) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 20 // 셀 높이는 40으로 고정되어있음.
        contentView.clipsToBounds = true
        contentView.addSubview(genreNameLabel)
        
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
        genreNameLabel.textColor = isSelected ? .white : .Main.primary
        let fontWeight: UIFont.Weight = isSelected ? .bold : .regular
        genreNameLabel.font = .systemFont(ofSize: 17, weight:  fontWeight)
        contentView.backgroundColor = isSelected ? .Main.primary : .Main.third
        
    }
    
    func configure(with model: HomeUIModel) {
        guard case .genre(let model) = model else {
            assertionFailure()
            return
        }
        genreNameLabel.text = model.description
    }
    
}
