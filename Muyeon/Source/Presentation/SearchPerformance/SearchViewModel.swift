//
//  SearchViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 10/1/25.
//

import Foundation

import RxSwift
import RxCocoa

final class SearchViewModel {
    
    struct Input {
        let searchButtonTapped: Observable<String>
    }
    
    struct Output {
        let performanceSearchResult: Observable<[Performance]>
    }
    
    let fetchPerformanceListUseCase: any FetchPerformanceListUseCase
    
    private let disposeBag = DisposeBag()
    
    init(fetchPerformanceListUseCase: some FetchPerformanceListUseCase) {
        self.fetchPerformanceListUseCase = fetchPerformanceListUseCase
    }
    
    func transform(input: Input) -> Output {
        let searchResult = PublishRelay<[Performance]>()
        let errorRelay = PublishRelay<any Error>()
        
        input.searchButtonTapped
            .flatMap { searchText in
                return Observable<[Performance]>.create { observer in
                    let requestParam = PerformanceListRequestParameter(
                        stdate: .now.addingDay(-100),
                        eddate: .now.addingDay(+100),
                        cpage: 1,
                        rows: 50,
                        shprfnm: searchText,
                    )
                    
                    Task {
                        do {
                            let fetchedPerformances = try await self.fetchPerformanceListUseCase.execute(requestInfo: requestParam)
                            observer.onNext(fetchedPerformances)
                        } catch {
                            errorRelay.accept(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .bind(to: searchResult)
            .disposed(by: disposeBag)
        
        return .init(
            performanceSearchResult: searchResult.asObservable()
        )
    }
    
    
    
    
    
}
