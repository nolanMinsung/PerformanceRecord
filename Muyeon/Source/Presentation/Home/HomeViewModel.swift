//
//  HomeViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

import RxSwift
import RxCocoa

final class HomeViewModel {
    
    let fetchBoxOfficeUseCase: FetchBoxOfficeUseCase
    let fetchPerformanceListUseCase: FetchPerformanceListUseCase
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let topTenLoadingTrigger: Observable<Void>
        let trendingLoadingTrigger: Observable<Void>
        let itemSelected: ControlEvent<IndexPath>
    }
    
    struct Output {
        let topTenContents: BehaviorRelay<[BoxOfficeItem]>
        let boxOfficeGenres: BehaviorRelay<[Constant.BoxOfficeGenre]>
        let trendingContents: BehaviorRelay<[BoxOfficeItem]>
        let presentDetail: PublishRelay<(IndexPath, String)>
        let errorRelay: PublishRelay<any Error>
    }
    
    init(
        fetchBoxOfficeUseCase: some FetchBoxOfficeUseCase,
        fetchPerformanceListUseCase: some FetchPerformanceListUseCase
    ) {
        self.fetchBoxOfficeUseCase = fetchBoxOfficeUseCase
        self.fetchPerformanceListUseCase = fetchPerformanceListUseCase
    }
    
    func transform(input: Input) -> Output {
        let topTenContents = BehaviorRelay<[BoxOfficeItem]>(value: [])
        let boxOfficeGenres = BehaviorRelay<[Constant.BoxOfficeGenre]>(value: Constant.BoxOfficeGenre.allCases)
        let trendingBoxOffice = BehaviorRelay<[BoxOfficeItem]>(value: [])
        let presentDetail = PublishRelay<(IndexPath, String)>()
        let errorRelay = PublishRelay<any Error>()
        
        input.topTenLoadingTrigger
            .bind {
                let boxOfficeRequestParam = BoxOfficeRequestParameter(
                    service: InfoPlist.apiKey,
                    stdate: .now.addingDay(-2),
                    eddate: .now.addingDay(-2)
                )
                Task {
                    do {
                        let topTenBoxOfficeItems = try await self.fetchBoxOfficeUseCase.execute(requestInfo: boxOfficeRequestParam)
                        topTenContents.accept(topTenBoxOfficeItems)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        input.trendingLoadingTrigger
            .bind {
                let boxOfficeRequestParam = BoxOfficeRequestParameter(
                    service: InfoPlist.apiKey,
                    stdate: .now.addingDay(-2),
                    eddate: .now.addingDay(-2),
                    catecode: Constant.BoxOfficeGenre.allCases[0].rawValue
                )
                Task {
                    do {
                        let trendingBoxOfficeItems = try await self.fetchBoxOfficeUseCase.execute(requestInfo: boxOfficeRequestParam)
                        trendingBoxOffice.accept(trendingBoxOfficeItems)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        let genreSelected = input.itemSelected
            .filter { $0.section == 1 }
        
        genreSelected
            .map { boxOfficeGenres.value[$0.item] }
            .bind { genre in
                let parameter = BoxOfficeRequestParameter(
                    service: InfoPlist.apiKey,
                    stdate: .now.addingDay(-2),
                    eddate: .now.addingDay(-1),
                    catecode: genre.rawValue,
                )
                Task {
                    do {
                        let boxOfficeListResult = try await self.fetchBoxOfficeUseCase.execute(requestInfo: parameter)
                        trendingBoxOffice.accept(boxOfficeListResult)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        
        let trendingItemSelected = input.itemSelected
            .filter { $0.section == 2 }
        
        trendingItemSelected
            .map {
                let performanceID = trendingBoxOffice.value[$0.item].id
                return ($0, performanceID)
            }
            .bind(to: presentDetail)
            .disposed(by: disposeBag)
        
        return .init(
            topTenContents: topTenContents,
            boxOfficeGenres: boxOfficeGenres,
            trendingContents: trendingBoxOffice,
            presentDetail: presentDetail,
            errorRelay: errorRelay
        )
    }
    
}
