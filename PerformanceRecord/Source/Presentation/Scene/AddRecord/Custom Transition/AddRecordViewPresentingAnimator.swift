//
//  AddRecordViewPresentingAnimator.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/21/25.
//

import UIKit

import SnapKit

final class AddRecordViewPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        toView.frame = containerView.frame
        toView.bounds.origin.y -= toView.bounds.size.height
        containerView.layoutIfNeeded()
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            animations: { toView.bounds.origin = .zero },
            completion: { transitionContext.completeTransition($0) }
        )
    }
    
    
}
