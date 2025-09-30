//
//  BottomGradientView.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

// traitChange 관련 버전별 분기처리는 더 간단하게 할 수 있으나,(traitCollectionDidChange override만)
// 공부 목적으로 registerForTraitChanges 메서드도 구현하였음.

class BottomGradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    private let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        layer.addSublayer(gradientLayer)
        updateGradientColors()
        if #available(iOS 17.0, *) {
            registerForTraitChanges()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    @available(iOS 17.0, *)
    private func registerForTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (view: Self, previousTraitCollection) in
            self?.updateGradientColors()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 17.0, *) { return }
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradientColors()
        }
    }
    
    private func updateGradientColors() {
        let topColor = color.withAlphaComponent(0.0).cgColor
        let bottomColor = color.cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.8)
    }
    
}
