//
//  PerformanceDetailViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import Foundation

final class PerformanceDetailViewModel {
    
    let fetchPerformanceDetailUseCase: any FetchPerformanceDetailUseCase
    
    init(fetchPerformanceDetailUseCase: some FetchPerformanceDetailUseCase) {
        self.fetchPerformanceDetailUseCase = fetchPerformanceDetailUseCase
    }
    
}
