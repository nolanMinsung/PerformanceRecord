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
        let searchTried: Observable<String>
        let fromDate: Observable<Date>
        let toDate: Observable<Date>
        let genreSelected: Observable<Constant.Genre?>
    }
    
    struct Output {
        let genreselected: Observable<Constant.Genre?>
        let fromDate: Observable<Date>
        let performanceSearchResult: Observable<[Performance]>
        let error: Observable<any Error>
    }
    
    let fetchPerformanceListUseCase: any FetchPerformanceListUseCase
    
    private let disposeBag = DisposeBag()
    
    init(fetchPerformanceListUseCase: some FetchPerformanceListUseCase) {
        self.fetchPerformanceListUseCase = fetchPerformanceListUseCase
    }
    
    func transform(input: Input) -> Output {
        let fromDate = PublishRelay<Date>()
        let searchResult = PublishRelay<[Performance]>()
        let errorRelay = PublishRelay<any Error>()
        
        input.searchTried
            .withLatestFrom(input.fromDate) { $1 }
            .withLatestFrom(input.toDate) { ($0, $1) }
            .map { values in
                let (fromDate, toDate) = values
                return fromDate < toDate ? fromDate : toDate
            }
            .bind(to: fromDate)
            .disposed(by: disposeBag)
        
        input.searchTried
            .withLatestFrom(input.genreSelected, resultSelector: { return ($0, $1) })
            .withLatestFrom(input.fromDate, resultSelector: { return ($0.0, $0.1, $1) })
            .withLatestFrom(input.toDate, resultSelector: { return ($0.0, $0.1, $0.2, $1) })
            .flatMap { value in
                let (searchText, genre, fromDate, toDate) = value
                return Observable<[Performance]>.create { observer in
                    let requestParam = PerformanceListRequestParameter(
                        stdate: (fromDate < toDate) ? fromDate : toDate,
                        eddate: toDate,
                        cpage: 1,
                        rows: 50,
                        shprfnm: searchText,
                        shcate: genre?.rawValue
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
            genreselected: input.genreSelected,
            fromDate: fromDate.asObservable(),
            performanceSearchResult: searchResult.asObservable(),
            error: errorRelay.asObservable()
        )
    }
    
    
    
    
    
}
