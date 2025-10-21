//
//  AddRecordPresentationController.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/21/25.
//

import UIKit

import SnapKit

final class AddRecordPresentationController: UIPresentationController {
    
    private let dimmingView = UIView()
    private let blurView = UIVisualEffectView(effect: nil)
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        dimmingView.backgroundColor = .darkGray
        dimmingView.isUserInteractionEnabled = false
        blurView.isUserInteractionEnabled = false
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        dimmingView.alpha = 0.0
        containerView?.addSubview(blurView)
        
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            return
        }
        
        coordinator.animate { [weak self] context in
            guard let self else { return }
            self.dimmingView.alpha = 0.4
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            return
        }
        
        coordinator.animate { [weak self] context in
            guard let self else { return }
            self.dimmingView.alpha = 0.0
            self.blurView.effect = nil
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
    
}
