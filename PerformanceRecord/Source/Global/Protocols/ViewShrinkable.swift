//
//  ViewShrinkable.swift
//  Muyeon
//
//  Created by 김민성 on 10/9/25.
//

import UIKit

protocol ViewShrinkable: UIView {
    func shrink(duration: TimeInterval, scale: CGFloat)
    func restore(duration: TimeInterval)
}

extension ViewShrinkable {
    
    func shrink(duration: TimeInterval = 0.5, scale: CGFloat) {
        UIView.springAnimate(withDuration: duration, options: .allowUserInteraction) { [weak self] in
            self?.transform = .init(scaleX: scale, y: scale)
        }
    }
    
    func restore(duration: TimeInterval = 0.4) {
        UIView.springAnimate(withDuration: duration, options: .allowUserInteraction) { [weak self] in
            self?.transform = .identity
        }
    }
    
}
