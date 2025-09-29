//
//  HomeViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

final class HomeViewModel {
    
    let fetchBoxOfficeUseCase: FetchBoxOfficeUseCase
    let fetchPerformanceListUseCase: FetchPerformanceListUseCase
    
    init(
        fetchBoxOfficeUseCase: some FetchBoxOfficeUseCase,
        fetchPerformanceListUseCase: some FetchPerformanceListUseCase
    ) {
        self.fetchBoxOfficeUseCase = fetchBoxOfficeUseCase
        self.fetchPerformanceListUseCase = fetchPerformanceListUseCase
    }
    
}
