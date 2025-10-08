//
//  UIView+.swift
//  Muyeon
//
//  Created by 김민성 on 10/9/25.
//

import UIKit

extension UIView {
    
    static func springAnimate(
        withDuration: TimeInterval,
        delay: TimeInterval = 0,
        dampingRatio: CGFloat = 1,
        options: AnimationOptions = [],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        self.animate(
            withDuration: withDuration,
            delay: delay,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: 1,
            options: options,
            animations: animations,
            completion: completion
        )
    }
    
}
