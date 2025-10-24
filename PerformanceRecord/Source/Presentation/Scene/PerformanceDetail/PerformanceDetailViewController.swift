//
//  PerformanceDetailViewController.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

import RxSwift

class PerformanceDetailViewController: UIViewController {
    
    private let rootView = PerformanceDetailView()
    private let container: DIContainer
    private let viewModel: PerformanceDetailViewModel
    private let addRecordVCTransitioningDelegate = AddRecordViewTransitioningDelegate()
    
    private let disposeBag = DisposeBag()
    
    init(performanceID: String, posterURL: String, posterThumbnail: UIImage? = nil, container: DIContainer) {
        self.container = container
        self.viewModel = PerformanceDetailViewModel(
            performanceID: performanceID,
            posterURL: posterURL,
            fetchRemotePerformanceDetailUseCase: container.resolve(type: FetchRemotePerformanceDetailUseCase.self),
            togglePerformanceLikeUseCase: container.resolve(type: TogglePerformanceLikeUseCase.self)
        )
        super.init(nibName: nil, bundle: nil)
        if let posterThumbnail {
            rootView.updatePosterImage(withThumbnail: posterThumbnail)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        bind()
    }
    
}


private extension PerformanceDetailViewController {
    
    func bind() {
        let likeButtonTapped = rootView.likeButton.rx.tap.asObservable()
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(rootView.likeButton) { button, _ in button }
            .map(\.isSelected)
            .share()
            
        let input = PerformanceDetailViewModel.Input(
            likeButtonTapped: likeButtonTapped.asObservable(),
            facilityButtonTapped: rootView.facilityButton.rx.tap.asObservable(),
            addRecordButtonTapped: rootView.addRecordButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.posterURL
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, posterURL in
                    owner.rootView.updatePosterImageView(with: posterURL)
                }
            )
            .disposed(by: disposeBag)
        
        output.performanceDetail
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, performance in
                    owner.rootView.update(with: performance)
                    owner.rootView.facilityButton.isEnabled = (performance.detail != nil)
                }
            )
            .disposed(by: disposeBag)
        
        output.showFacilityDetail
            .bind(
                with: self,
                onNext: { owner, facilityID in
                    owner.navigationController?.pushViewController(
                        FacilityDetailViewController(facilityID: facilityID, container: owner.container),
                        animated: true
                    )
                }
            )
            .disposed(by: disposeBag)
        
        output.likeButtonSelectionState
            .bind(to: rootView.likeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.error
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, error in
                print(error.localizedDescription)
                owner.wisp.dismiss(autoFallback: true)
            }
            .disposed(by: disposeBag)
        
        output.showAddRecordVC
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, performance in
                    let addRecordVC = AddRecordViewController(performance: performance, container: owner.container)
                    addRecordVC.modalPresentationStyle = .custom
                    addRecordVC.transitioningDelegate = owner.addRecordVCTransitioningDelegate
                    owner.present(addRecordVC, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
    
}
