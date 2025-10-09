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
    
    private let filteringOptionContainer = UIView()
    private let separator = UIView()
    private let mainTitleLabel = UILabel()
    
    let searchBarContainer = UIView()
    let searchTextField = UITextField()
    let searchButton = UIButton()
    
    let genreLabel = UILabel()
    let genreSelectionButton = ShrinkableButton(configuration: .filled())
    
    let datePickingLabel = UILabel()
    let fromDatePicker = UIDatePicker()
    let tildeLabel = UILabel()
    let toDatePicker = UIDatePicker()
    
    let performanceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 150)
        layout.minimumLineSpacing = 16
        layout.sectionInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupUIProperties() {
        self.backgroundColor = .systemGray6
        
        filteringOptionContainer.backgroundColor = .systemBackground
        
        separator.backgroundColor = .systemGray4
        
        mainTitleLabel.text = "공연 검색"
        mainTitleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        
        searchBarContainer.layer.borderColor = UIColor.Main.primary.withAlphaComponent(0.5).cgColor
        searchBarContainer.layer.borderWidth = 1.5
        searchBarContainer.layer.cornerRadius = 22
        
        searchTextField.placeholder = "어떤 공연을 찾으시나요?"
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .Main.primary
        
        genreLabel.text = "장르"
        genreLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        genreSelectionButton.configuration?.title = "장르"
        genreSelectionButton.configuration?.baseBackgroundColor = .Main.third
        genreSelectionButton.configuration?.baseForegroundColor = .Main.primary
        genreSelectionButton.configuration?.cornerStyle = .capsule
        genreSelectionButton.showsMenuAsPrimaryAction = true
        
        datePickingLabel.text = "날짜 범위"
        datePickingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        fromDatePicker.datePickerMode = .date
        fromDatePicker.preferredDatePickerStyle = .compact
        fromDatePicker.calendar = Calendar(identifier: .gregorian)
        
        tildeLabel.text = "~"
        tildeLabel.font = .systemFont(ofSize: 17)
        
        toDatePicker.datePickerMode = .date
        toDatePicker.preferredDatePickerStyle = .compact
        toDatePicker.calendar = Calendar(identifier: .gregorian)
        
        // CollectionView
        performanceCollectionView.backgroundColor = .clear
        performanceCollectionView.showsVerticalScrollIndicator = false
        performanceCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func setupHierarchy() {
        addSubview(filteringOptionContainer)
        addSubview(separator)
        addSubview(mainTitleLabel)
        addSubview(searchBarContainer)
        searchBarContainer.addSubview(searchTextField)
        searchBarContainer.addSubview(searchButton)
        addSubview(genreLabel)
        addSubview(genreSelectionButton)
        addSubview(datePickingLabel)
        addSubview(tildeLabel)
        addSubview(fromDatePicker)
        addSubview(toDatePicker)
        addSubview(performanceCollectionView)
    }
    
    private func setupLayoutConstraints() {
        filteringOptionContainer.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(toDatePicker.snp.bottom).offset(15)
        }
        
        separator.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(filteringOptionContainer)
            make.height.equalTo(1)
        }
        
        mainTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(25)
            make.leading.equalToSuperview().inset(20)
        }
        
        searchBarContainer.snp.makeConstraints { make in
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        searchTextField.snp.contentHuggingHorizontalPriority = 230
        searchTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchTextField)
            make.leading.equalTo(searchTextField.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(44)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.top.centerY.equalTo(genreSelectionButton)
            make.leading.equalTo(searchBarContainer)
        }
        
        genreSelectionButton.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(10)
            make.leading.equalTo(genreLabel.snp.trailing).offset(10)
        }
        
        datePickingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(fromDatePicker)
            make.leading.equalTo(searchBarContainer)
        }
        
        fromDatePicker.snp.makeConstraints { make in
            make.top.equalTo(genreLabel.snp.bottom).offset(10)
            make.leading.equalTo(datePickingLabel.snp.trailing).offset(10)
        }
        
        tildeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(fromDatePicker)
            make.leading.equalTo(fromDatePicker.snp.trailing).offset(3)
        }
        
        toDatePicker.snp.makeConstraints { make in
            make.centerY.equalTo(fromDatePicker)
            make.leading.equalTo(tildeLabel.snp.trailing).offset(3)
        }
        
        performanceCollectionView.snp.makeConstraints { make in
            make.top.equalTo(filteringOptionContainer.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
}
