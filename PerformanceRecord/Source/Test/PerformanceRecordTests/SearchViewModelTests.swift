//
//  SearchViewModelTests.swift
//  PerformanceRecord
//
//  Created by 김민성 on 12/20/25.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import PerformanceRecord
final class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    var disposeBag: DisposeBag!
    
    // Mocks
    var mockFetchListUseCase: MockFetchRemotePerformanceListUseCase!
    var mockFetchDetailUseCase: MockFetchRemotePerformanceDetailUseCase!
    var mockToggleLikeUseCase: MockTogglePerformanceLikeUseCase!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        mockFetchListUseCase = MockFetchRemotePerformanceListUseCase()
        mockFetchDetailUseCase = MockFetchRemotePerformanceDetailUseCase()
        mockToggleLikeUseCase = MockTogglePerformanceLikeUseCase()
        
        viewModel = SearchViewModel(
            fetchPerformanceListUseCase: mockFetchListUseCase,
            fetchPerformanceDetailUseCase: mockFetchDetailUseCase,
            togglePerformanceLikeUseCase: mockToggleLikeUseCase
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
        mockFetchListUseCase = nil
        mockFetchDetailUseCase = nil
        mockToggleLikeUseCase = nil
    }

    func test_searchTried_emits_performanceList() throws {
        // Given
        let expectation = XCTestExpectation(description: "Search Result Emitted")
        let dummyPerformance = Performance(
            id: "ID123",
            name: "Test Performance",
            startDate: Date(),
            endDate: Date(),
            facilityFullName: "Test Hall",
            posterURL: "http://example.com/poster.jpg",
            posterImageID: nil,
            area: .seoul,
            genre: .play,
            openRun: false,
            state: .ongoing,
            records: [],
            detail: nil
        )
        mockFetchListUseCase.result = [dummyPerformance]
        
        let searchTried = PublishSubject<String>()
        let fromDate = BehaviorSubject<Date>(value: Date())
        let toDate = BehaviorSubject<Date>(value: Date().addingTimeInterval(86400))
        let genreSelected = BehaviorSubject<Constant.Genre?>(value: nil)
        let likeButtonTapped = PublishSubject<(IndexPath, String)>()
        
        let input = SearchViewModel.Input(
            searchTried: searchTried.asObservable(),
            fromDate: fromDate.asObservable(),
            toDate: toDate.asObservable(),
            genreSelected: genreSelected.asObservable(),
            likeButtonTapped: likeButtonTapped.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // When
        output.performanceSearchResult
            .subscribe(onNext: { performances in
                // Then
                XCTAssertEqual(performances.count, 1)
                XCTAssertEqual(performances.first?.id, "ID123")
                XCTAssertEqual(performances.first?.name, "Test Performance")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        searchTried.onNext("Test Query")
        
        wait(for: [expectation], timeout: 2.0)
    }
    
}
