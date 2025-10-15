//
//  PhotoViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit

import SnapKit

class PhotoViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0 // 4배까지 확대
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // 확대/축소를 위해 필요
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        return button
    }()
    
    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        // TODO: - 이미지 값 nil 처리(에러 케이스)
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        scrollView.delegate = self
        
        setupUI()
        setupLayout()
        setupGestures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(closeButton)
    }
    
    private func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.height.equalTo(scrollView.frameLayoutGuide)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(44)
        }
    }
    
    private func setupGestures() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    // MARK: - Actions
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            // 확대
            let location = gesture.location(in: gesture.view)
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale / 2, center: location)
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            // 축소
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    // MARK: - Helper
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
}


// MARK: - UIScrollViewDelegate
extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView // 줌할 뷰로 imageView를 지정
    }
}

