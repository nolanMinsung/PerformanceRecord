//
//  AddRecordViewDismissingAnimator.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/21/25.
//

import UIKit

import SnapKit

final class AddRecordViewDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        
        fromView.frame = containerView.frame
        fromView.bounds.origin.y = 0
        containerView.layoutIfNeeded()
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            animations: { fromView.bounds.origin.y -= fromView.bounds.size.height },
            completion: { transitionContext.completeTransition($0) }
        )
    }
    
    
}

