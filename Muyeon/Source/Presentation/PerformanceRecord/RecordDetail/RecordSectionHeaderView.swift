//
//  RecordSectionHeaderView.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit

import SnapKit

class RecordSectionHeaderView: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(count: Int) {
        titleLabel.text = "관람 기록 (\(count))"
    }
}

