//
//  BottomGradientView.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

class BottomGradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    private let color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        let topColor = color.withAlphaComponent(0.0).cgColor
        let bottomColor = color.cgColor
        gradientLayer.colors = [topColor, bottomColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
}
