//
//  HomeBoxOfficeGenreCell.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

class HomeBoxOfficeGenreCell: UICollectionViewCell {
    
    private let genreNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.addSubview(genreNameLabel)
        
        genreNameLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: HomeUIModel) {
        guard case .genre(let model) = model else {
            assertionFailure()
            return
        }
        genreNameLabel.text = model.description
    }
    
}
