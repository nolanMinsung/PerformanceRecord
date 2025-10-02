//
//  SearchView.swift
//  Muyeon
//
//  Created by 김민성 on 10/1/25.
//

import UIKit
import SnapKit

final class SearchView: UIView {
    
    // MARK: - UI Components
    
    let searchTextField = UITextField()
    // 장르 버튼은 UI 배치를 위해 임시 할당한 것이고, 추후 collectionView 등으로 교체 예정.
    let magicButton = UIButton(type: .system)
    let classicButton = UIButton(type: .system)
    let musicalButton = UIButton(type: .system)
    private let filterStackView = UIStackView()
    
    let dateSelectionButton = UIButton(type: .system)
    let performanceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 150)
        layout.minimumLineSpacing = 16
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Setup Methods

    private func commonInit() {
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
    }
    
    private func setupUIProperties() {
        self.backgroundColor = .systemBackground

        // Search TextField
        searchTextField.placeholder = "어떤 공연을 찾으시나요?"

        // Filter Buttons
        configureFilterButton(magicButton, title: "마술")
        configureFilterButton(classicButton, title: "클래식")
        configureFilterButton(musicalButton, title: "뮤지컬")
        
        // Filter StackView
        filterStackView.axis = .horizontal
        filterStackView.spacing = 8
        filterStackView.distribution = .fillProportionally

        // Date Selection Button
        var dateConfig = UIButton.Configuration.plain()
        dateConfig.title = "날짜 선택"
        dateConfig.image = UIImage(systemName: "chevron.down")
        dateConfig.imagePlacement = .trailing
        dateConfig.imagePadding = 4
        dateConfig.baseForegroundColor = .label
        dateSelectionButton.configuration = dateConfig
        dateSelectionButton.backgroundColor = .systemGray6
        dateSelectionButton.layer.cornerRadius = 8
        dateSelectionButton.contentHorizontalAlignment = .left
        dateConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        dateSelectionButton.configuration = dateConfig
        
        // CollectionView
        performanceCollectionView.backgroundColor = .clear
        performanceCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func setupHierarchy() {
        addSubview(searchTextField)
        
        [magicButton, classicButton, musicalButton].forEach {
            filterStackView.addArrangedSubview($0)
        }
        addSubview(filterStackView)
        
        addSubview(dateSelectionButton)
        addSubview(performanceCollectionView)
    }
    
    private func setupLayoutConstraints() {
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        filterStackView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(20)
        }
        
        dateSelectionButton.snp.makeConstraints { make in
            make.top.equalTo(filterStackView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        performanceCollectionView.snp.makeConstraints { make in
            make.top.equalTo(dateSelectionButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Helper Methods
    
    private func configureFilterButton(_ button: UIButton, title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemGray5
        config.baseForegroundColor = .darkGray
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        button.configuration = config
    }
    
}
