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
    private var blurAnimator: UIViewPropertyAnimator!
    
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
        
        blurAnimator = UIViewPropertyAnimator(
            duration: 0.5 * 4,
            controlPoint1: .init(x: 0.2, y: 0.5),
            controlPoint2: .init(x: 0.7, y: 0.0)
        )
        blurAnimator.addAnimations { [weak self] in
            guard let self else { return }
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        blurAnimator.startAnimation()
        
        coordinator.animate { [weak self] context in
            guard let self else { return }
            self.dimmingView.alpha = 0.4
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        blurAnimator.pauseAnimation()
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            return
        }
        
        blurAnimator.isReversed = true
        let springTimingParameter = UISpringTimingParameters(dampingRatio: 1)
        if blurAnimator.state == .active {
            blurAnimator.continueAnimation(withTimingParameters: springTimingParameter, durationFactor: 0.25)
        } else {
            // 앱을 나갔다 들어오거나 화면을 껐다 킨 경우 -> animator의 state가 .active가 아님
            // (pause해놓은 설정이 풀리며 completionHandler 호출)
            UIView.springAnimate(withDuration: 0.5) { [weak self] in
                guard let self else { return }
                self.blurView.effect = nil
            }
        }
        
        coordinator.animate { [weak self] context in
            guard let self else { return }
            self.dimmingView.alpha = 0.0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
    
}
