//
//  SelectPerformanceView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class SelectPerformanceView: UIView {
    
    let collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(250)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            PerformanceSelectionCell.self,
            forCellWithReuseIdentifier: PerformanceSelectionCell.reuseIdentifier
        )
        return collectionView
    }()
    
    let continueButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "이 공연을 봤어요"
        config.baseBackgroundColor = .label
        config.baseForegroundColor = .systemBackground
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // UI 컴포넌트 생성
        let titleLabel = UILabel()
        titleLabel.text = "공연 검색하기"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "어떤 공연을 관람하셨나요?\n이전에 기록한 공연이라면 목록에서 선택하세요."
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        let addNewPerformanceButton: UIButton = {
            var config = UIButton.Configuration.filled()
            config.title = "새 공연 추가"
            config.image = UIImage(systemName: "plus")
            config.baseBackgroundColor = .systemGray5
            config.baseForegroundColor = .label
            config.imagePadding = 6
            return UIButton(configuration: config)
        }()
        
        // 레이아웃 구성
        let buttonStack = UIStackView(arrangedSubviews: [addNewPerformanceButton, continueButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, collectionView, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        
        addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview().inset(24)
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
}
