//
//  AddedPhotoCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class AddedPhotoCell: UICollectionViewCell {
    static let identifier = "AddedPhotoCell"
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onDelete: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(4)
            make.width.height.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
}
