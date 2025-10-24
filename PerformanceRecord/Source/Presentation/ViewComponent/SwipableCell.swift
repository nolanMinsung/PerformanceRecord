//
//  SwipableCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/8/25.
//

import UIKit

import SnapKit

class SwipableCell: UICollectionViewCell {
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    private var accommodationID: Int = 0
    private var roomID: Int = 0
    private var isBlueCircleFilled: Bool = false
    private var isRedCircleFilled: Bool = false
    private let horizontalInset: CGFloat = 0
    private let cornerRadius: CGFloat = 0
    
    private let leftImageName: String = {
        if #available(iOS 18.4, *) {
            return "long.text.page.and.pencil"
        } else {
            return "ticket"
        }
    }()
    private let rightImageName: String = "trash"
    
    var isLeftSwipeEnable: Bool = true
    var isRightSwipeEnable: Bool = true
    var leftSwipeAction: (() -> Void)?
    var rightSwipeAction: (() -> Void)?
    
    private let panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.maximumNumberOfTouches = 1
        return panGestureRecognizer
    }()
    
    let swipeableView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 18
        view.backgroundColor = .systemGray5
        return view
    }()
    
    /*
     bludView UI Components
     */
    
    private let blueViewLabel: UILabel = {
        let label = UILabel()
        label.text = "기록\n수정하기" // 임시 문구
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBackground
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let circleViewForAddInteraction: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = 30
        return view
    }()
    
    private var blueCirclePathLayer = CAShapeLayer()
    
    private lazy var addIconImageViewForBlueView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: self.leftImageName)?
            .withTintColor(
                .systemBackground.withAlphaComponent(1),
                renderingMode: .alwaysOriginal
            )
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let blueViewToAddCompare: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.clipsToBounds = true
        view.layer.cornerRadius = 19
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    /*
     blueView UIComponents 끝
     */
    
    /*
     redView UI Components
     */
    
    private let redViewLabel: UILabel = {
        let label = UILabel()
        label.text = "삭제하기"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBackground
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let circleViewForDeleteInteraction: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = 30
        return view
    }()
    
    private var redCirclePathLayer = CAShapeLayer()
    
    private lazy var deleteIconImageViewForRedView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: rightImageName)?
            .withTintColor(
                .systemBackground,
                renderingMode: .alwaysOriginal
            )
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let redViewToDeleteFromCompare: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed
        view.clipsToBounds = true
        view.layer.cornerRadius = 19
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    /*
     redView UI Components 끝
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        configureViewHierarchy()
        setConstraints()
        setGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.layer.cornerRadius = cornerRadius
        
    }
    
    private func configureViewHierarchy() {
        circleViewForAddInteraction.addSubview(addIconImageViewForBlueView)
        circleViewForDeleteInteraction.addSubview(deleteIconImageViewForRedView)
        
        blueViewToAddCompare.addSubview(blueViewLabel)
        blueViewToAddCompare.addSubview(circleViewForAddInteraction)
        redViewToDeleteFromCompare.addSubview(redViewLabel)
        redViewToDeleteFromCompare.addSubview(circleViewForDeleteInteraction)
        
        contentView.addSubview(blueViewToAddCompare)
        contentView.addSubview(redViewToDeleteFromCompare)
        contentView.addSubview(swipeableView)
    }
    
    private func setConstraints() {
        blueViewToAddCompare.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(horizontalInset + cornerRadius + 10)
        }
        
        blueViewLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(17)
        }
        
        circleViewForAddInteraction.snp.makeConstraints { make in
            make.centerY.equalTo(blueViewLabel)
            make.leading.equalTo(blueViewLabel.snp.trailing).offset(30)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        addIconImageViewForBlueView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(23)
        }
        
        redViewToDeleteFromCompare.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(horizontalInset + cornerRadius + 10)
        }
        
        redViewLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(17)
        }
        
        circleViewForDeleteInteraction.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(redViewLabel.snp.leading).offset(-30)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        deleteIconImageViewForRedView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        swipeableView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(horizontalInset)
        }
    }
    
    func setGestureRecognizers() {
        panGestureRecognizer.allowedScrollTypesMask = [.continuous]
        swipeableView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(sender:)))
    }
    
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .possible, .began:
            let xVelocity = sender.velocity(in: swipeableView).x
            guard (xVelocity < 0 && isLeftSwipeEnable) || (xVelocity > 0 && isRightSwipeEnable) else {
                sender.state = .ended
                return
            }
            feedbackGenerator.prepare()
            return
        case .changed:
            let swipableViewXFrame = swipeableView.frame.origin.x
            
            blueViewToAddCompare.isHidden = swipableViewXFrame < 0
            redViewToDeleteFromCompare.isHidden = swipableViewXFrame > horizontalInset * 2
            
            let translatedLocation = sender.translation(in: contentView)
            
            let circleScaleProportion = 1 + 0.3 * (abs(swipeableView.frame.origin.x) / (bounds.width * 0.55))
            let addIconScaleProportion = 1 + 0.5 * (abs(swipeableView.frame.origin.x) / (bounds.width * 0.55))
            
            if translatedLocation.x > 0 {
                let maxPosition = isRightSwipeEnable ? bounds.width * 0.55 : 0.0
                swipeableView.frame.origin.x = min(translatedLocation.x, maxPosition) + horizontalInset
                drawCircleAtBlueView(circlePercentage: (swipeableView.frame.origin.x) / (bounds.width * 0.55))
                circleViewForAddInteraction.transform = .init(scaleX: circleScaleProportion, y: circleScaleProportion)
                addIconImageViewForBlueView.transform = .init(scaleX: addIconScaleProportion, y: addIconScaleProportion)
            } else if translatedLocation.x < 0 {
                let minPosition = isLeftSwipeEnable ? -bounds.width * 0.55 : 0.0
                swipeableView.frame.origin.x = max(translatedLocation.x, minPosition) + horizontalInset
                drawCircleAtRedView(circlePercentage: (swipeableView.frame.origin.x) / (bounds.width * 0.55))
                circleViewForDeleteInteraction.transform = .init(scaleX: circleScaleProportion, y: circleScaleProportion)
                deleteIconImageViewForRedView.transform = .init(scaleX: addIconScaleProportion, y: addIconScaleProportion)
            }
            
            /*
             셀 너비의 55%이상 끌어왔을 때 시뮬레이터에서 동작하지 않는 경우가 있음.
             */
            let horizontalOffset = swipeableView.frame.origin.x
            let ceilHorizontalOffset = ceil(horizontalOffset)
            let floorHorizontalOffset = floor(horizontalOffset)
            
            if ceilHorizontalOffset >= bounds.width * 0.55 {
                if !isBlueCircleFilled {
                    fillBlueCircle() {
                        sender.state = .ended
                    }
                }
                
            } else if floorHorizontalOffset < -bounds.width * 0.55 {
                if !isRedCircleFilled {
                    fillRedCircle() {
                        sender.state = .ended
                    }
                }
            }
        default:
            setSwipeableViewToInitialLocaion()
        }
    }
    
    private func setSwipeableViewToInitialLocaion() {
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1)
        animator.addAnimations { [weak self] in
            guard let self else { return }
            self.swipeableView.frame = .zero
            self.circleViewForAddInteraction.transform = CGAffineTransform.identity
            self.circleViewForDeleteInteraction.transform = CGAffineTransform.identity
            self.contentView.layoutIfNeeded()
        }

        animator.addCompletion { [weak self] position in
            guard let self else { return }
            self.emptyBlueCircle()
            self.emptyRedCircle()
        }
        animator.startAnimation()
    }
    
    /// 원에 해당하는 UIBezierPath를 layer로 추가해주는 함수
    /// - Parameters:
    ///   - circlePercentage: 원이 그려질 비율 %를 100으로 나눈 값. 0.0 ~ 1.0
    private func drawCircleAtBlueView(circlePercentage: CGFloat) {
        blueCirclePathLayer.removeFromSuperlayer()
        
        let path: UIBezierPath = getPath(percentage: circlePercentage)
        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = path.cgPath
        shape.strokeColor = UIColor.systemBackground.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        blueCirclePathLayer = shape
        circleViewForAddInteraction.layer.addSublayer(blueCirclePathLayer)
    }
    
    private func drawCircleAtRedView(circlePercentage: CGFloat) {
        redCirclePathLayer.removeFromSuperlayer()
        
        let path: UIBezierPath = getPath(percentage: circlePercentage, clockwise: false)
        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = path.cgPath
        shape.strokeColor = UIColor.systemBackground.cgColor
        shape.fillColor = UIColor.clear.cgColor
        
        redCirclePathLayer = shape
        circleViewForDeleteInteraction.layer.addSublayer(redCirclePathLayer)
    }
        
    /// 특정 각도만큼의 호에 해당하는 UIBezierPath를 반환하는 함수
    /// - Parameter percentage: 원이 몇 % 그려졌는지를 입력. %를 100으로 나눈 값(0.0 ~ 1.0)을 입력.
    /// - Returns: 그려진 호에 해당하는 UIBezierPath
    private func getPath(percentage: CGFloat, clockwise: Bool = true) -> UIBezierPath {
        let path: UIBezierPath = UIBezierPath()
        let radius = circleViewForAddInteraction.bounds.width / 2
        //let radius: CGFloat = 50
        
        path.move(to: CGPoint(x: radius, y: 0))
        path.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: -.pi * 0.5, endAngle: -(.pi * 0.5) + (2 * .pi * percentage), clockwise: clockwise)
        
        return path
    }
        
    /// 파란색 원을 채우는 함수. 애니메이션을 실행시킴. (비동기)
    /// - Parameter completion: 애니메이션이 끝나고 호출될 함수
    private func fillBlueCircle(completion: (() -> Void)? = nil) {
        feedbackGenerator.notificationOccurred(.success)
        isBlueCircleFilled = true
        rightSwipeAction?()
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1)
        animator.addAnimations { [weak self] in
            guard let self else { return }
            circleViewForAddInteraction.backgroundColor = .systemBackground
            addIconImageViewForBlueView.image = UIImage(systemName: leftImageName)?.withTintColor(
                UIColor.systemBlue,
                renderingMode: .alwaysOriginal
            )
            layoutIfNeeded()
        }
        
        animator.addCompletion { position in completion?() }
        animator.startAnimation()
    }
    
    /// 파란색 원을 비우는 함수. 애니메이션이 아님.
    private func emptyBlueCircle() {
        isBlueCircleFilled = false
        circleViewForAddInteraction.backgroundColor = .clear
        addIconImageViewForBlueView.image = UIImage(systemName: leftImageName)?.withTintColor(
            UIColor.systemBackground,
            renderingMode: .alwaysOriginal
        )
    }
    
    /// 빨간색 원을 채우는 함수. 애니메이션을 실행시킴. (비동기)
    /// - Parameter completion: 애니메이션이 끝나고 호출될 함수
    private func fillRedCircle(completion: (() -> Void)? = nil) {
        feedbackGenerator.notificationOccurred(.success)
        isRedCircleFilled = true
        leftSwipeAction?()
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1)
        animator.addAnimations { [weak self] in
            guard let self else { return }
            circleViewForDeleteInteraction.backgroundColor = .systemBackground
            deleteIconImageViewForRedView.image = UIImage(systemName: rightImageName)?.withTintColor(
                UIColor.systemRed,
                renderingMode: .alwaysOriginal
            )
            layoutIfNeeded()
        }
        
        animator.addCompletion { position in completion?() }
        animator.startAnimation()
    }
    
    /// 빨간색 원을 비우는 함수. 애니메이션이 아님.
    private func emptyRedCircle() {
        isRedCircleFilled = false
        circleViewForDeleteInteraction.backgroundColor = .clear
        deleteIconImageViewForRedView.image = UIImage(systemName: rightImageName)?.withTintColor(
            UIColor.systemBackground,
            renderingMode: .alwaysOriginal
        )
    }
    
}


extension SwipableCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        
        let xVelocityAbs = abs(panGestureRecognizer.velocity(in: contentView).x)
        let yVelocityAbs = abs(panGestureRecognizer.velocity(in: contentView).y)
        let ratio = yVelocityAbs / xVelocityAbs
        //if xVelocity > 30 || xVelocity < -30 {
        if ratio < 1 {
            return true
        } else {
            return false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
