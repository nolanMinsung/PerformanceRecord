//
//  ModalCardViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

class ModalCardViewController: UIViewController {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(30)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
