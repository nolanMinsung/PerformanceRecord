//
//  ViewShrinkable.swift
//  Muyeon
//
//  Created by 김민성 on 10/9/25.
//

import UIKit

protocol ViewShrinkable: UIView {
    func shrink(duration: TimeInterval, scale: CGFloat, isBubble: Bool)
    func restore(duration: TimeInterval, isBubble: Bool)
}

extension ViewShrinkable {
    
    func shrink(duration: TimeInterval = 0.5, scale: CGFloat, isBubble: Bool = false) {
        if isBubble {
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 1,
                options: .allowUserInteraction
            ) { [weak self] in
                self?.transform = .init(scaleX: scale, y: scale)
            }
        } else {
            UIView.springAnimate(withDuration: duration, options: .allowUserInteraction) { [weak self] in
                self?.transform = .init(scaleX: scale, y: scale)
            }
        }
    }
    
    func restore(duration: TimeInterval = 0.4, isBubble: Bool = false) {
        if isBubble {
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 1,
                options: .allowUserInteraction
            ) { [weak self] in
                self?.transform = .identity
            }
        } else {
            UIView.springAnimate(withDuration: duration, options: .allowUserInteraction) { [weak self] in
                self?.transform = .identity
            }
        }
    }
    
}
