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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            PerformanceSelectionCell.self,
            forCellWithReuseIdentifier: PerformanceSelectionCell.reuseIdentifier
        )
        return collectionView
    }()
    
    let addRecordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "공연 기록 남기기"
        config.baseBackgroundColor = .Main.primary.withAlphaComponent(0.1)
        config.baseForegroundColor = .Main.primary
        config.titleTextAttributesTransformer = .init({ incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            return outgoing
        })
        let button = UIButton(configuration: config)
        button.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // UI 컴포넌트 생성
        let titleLabel = UILabel()
        titleLabel.text = "즐겨찾기한 공연 목록이에요."
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "다음 중 관람하신 공연이 있나요?\n나만의 기록을 작성해 보세요."
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 16
        
        addSubview(titleStack)
        addSubview(collectionView)
        addSubview(addRecordButton)
        
        titleStack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(titleStack)
        }
        
        addRecordButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(titleStack)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
    }
}
