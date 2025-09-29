//
//  PerformanceDetailViewController.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import UIKit

class PerformanceDetailViewController: UIViewController {
    
    private let rootView = PerformanceDetailView()
    
    private let viewModel = PerformanceDetailViewModel(
        fetchPerformanceDetailUseCase: DefaultFetchPerformanceDetailUseCase()
    )
    
    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
    }
    
}
