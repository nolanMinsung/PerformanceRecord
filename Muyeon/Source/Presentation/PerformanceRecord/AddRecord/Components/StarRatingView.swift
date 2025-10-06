//
//  StarRatingView.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import RxSwift
import RxCocoa

final class StarRatingView: UIView {

    // MARK: - Properties

    public let ratingRelay = BehaviorRelay<Double>(value: 0.0)
    
    private let maxRating: Int = 5
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var starImageViews: [UIImageView] = []

    private var currentRating: Double = 0.0 {
        didSet {
            updateStarImages()
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup Methods

    private func setupView() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        for _ in 0..<maxRating {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemYellow
            starImageViews.append(imageView)
            stackView.addArrangedSubview(imageView)
        }
        
        setupGestures()
        updateStarImages()
    }

    // MARK: - Gestures
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        updateRating(for: location)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        updateRating(for: location)
    }

    // --- (변경) 탭과 드래그의 공통 로직 ---
    /// 터치 위치(CGPoint)를 기반으로 별점을 계산하고 UI와 상태를 업데이트
    private func updateRating(for location: CGPoint) {
        // 뷰의 너비가 0 이하일 경우 계산 오류를 방지
        guard self.bounds.width > 0 else { return }

        let percentage = max(0, min(1, location.x / self.bounds.width))
        let rawRating = percentage * Double(maxRating)
        let snappedRating = (rawRating * 2).rounded() / 2.0
        
        if snappedRating != currentRating {
            currentRating = snappedRating
            ratingRelay.accept(currentRating)
        }
    }

    // MARK: - UI Update

    private func updateStarImages() {
        for (index, imageView) in starImageViews.enumerated() {
            let starValue = Double(index + 1)
            if currentRating >= starValue {
                imageView.image = UIImage(systemName: "star.fill")
            } else if currentRating > starValue - 1 {
                imageView.image = UIImage(systemName: "star.leadinghalf.filled")
            } else {
                imageView.image = UIImage(systemName: "star")
            }
        }
    }
    
    // MARK: - Public Method
    
    public func setRating(_ rating: Double) {
        let clampedRating = max(0.0, min(Double(maxRating), rating))
        currentRating = clampedRating
        ratingRelay.accept(currentRating)
    }
}
