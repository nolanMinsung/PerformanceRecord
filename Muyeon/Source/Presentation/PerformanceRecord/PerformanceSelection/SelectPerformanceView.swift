//
//  SelectPerformanceView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class SelectPerformanceView: UIView {
    
    // ViewController에서 접근해야 하는 UI 컴포넌트
    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(PerformanceSelectionCell.self, forCellReuseIdentifier: PerformanceSelectionCell.identifier)
        tv.separatorStyle = .none
        tv.rowHeight = 100
        return tv
    }()
    
    let continueButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "선택한 공연으로 계속"
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
        titleLabel.text = "새 관람 기록 추가"
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
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, tableView, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        
        addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview().inset(24)
        }
        
        tableView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
}
