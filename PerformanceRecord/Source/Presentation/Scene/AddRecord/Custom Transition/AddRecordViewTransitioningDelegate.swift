//
//  AddRecordViewTransitioningDelegate.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/21/25.
//

import UIKit

final class AddRecordViewTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AddRecordPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return AddRecordViewPresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return AddRecordViewDismissingAnimator()
    }
    
}
