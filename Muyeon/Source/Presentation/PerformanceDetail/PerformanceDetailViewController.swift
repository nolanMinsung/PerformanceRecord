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
    private let viewModel: PerformanceDetailViewModel
    
    private let disposeBag = DisposeBag()
    
    init(performanceID: String, posterURL: String, posterThumbnail: UIImage? = nil) {
        self.viewModel = PerformanceDetailViewModel(
            performanceID: performanceID,
            posterURL: posterURL,
            fetchPerformanceDetailUseCase: DefaultFetchPerformanceDetailUseCase(),
            togglePerformanceLikeUseCase: DefaultTogglePerformanceLikeUseCase(),
            storePerformanceUseCase: DefaultStorePerformanceUseCase(
                repository: DefaultPerformanceRepository(
                    imageRepository: DefaultImageRepository(
                        remoteDataSource: DefaultRemoteImageDataSource(),
                        localDataSource: DefaultLocalImageDataSource()
                    )
                )
            )
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
            .withUnretained(rootView.likeButton) { button, _ in button }
            .map(\.isSelected)
            .share()
            
        let facilityButtonTapped = rootView.facilityButton.rx.tap
            .withLatestFrom(Observable.just(viewModel.performanceID))
        
        let input = PerformanceDetailViewModel.Input(
            likeButtonTapped: likeButtonTapped.asObservable(),
            facilityButtonTapped: facilityButtonTapped
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
                        FacilityDetailViewController(facilityID: facilityID),
                        animated: true
                    )
                }
            )
            .disposed(by: disposeBag)
        
        output.likeButtonSelectionState
            .bind(to: rootView.likeButton.rx.isSelected)
            .disposed(by: disposeBag)
    }
    
}
