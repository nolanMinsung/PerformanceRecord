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
            fetchPerformanceDetailUseCase: DefaultFetchPerformanceDetailUseCase()
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
        let buttonTapped = rootView.venueButton.rx.tap
            .withLatestFrom(Observable.just(viewModel.performanceID))
        
        let input = PerformanceDetailViewModel.Input(
            facilityButtonTapped: buttonTapped
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
                    owner.rootView.venueButton.isEnabled = (performance.detail != nil)
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
    }
    
}
