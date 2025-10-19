//
//  FacilityDetailViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 10/1/25.
//

import Foundation

final class FacilityDetailViewModel {
    
    let facilityID: String
    let fetchFacilityDetailUseCase: any FetchFacilityDetailUseCase
    
    init(
        facilityID: String,
        fetchFacilityDetailUseCase: some FetchFacilityDetailUseCase
    ) {
        self.facilityID = facilityID
        self.fetchFacilityDetailUseCase = fetchFacilityDetailUseCase
    }
    
}
