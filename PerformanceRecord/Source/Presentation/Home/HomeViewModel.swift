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
    let fetchPerformanceListUseCase: FetchRemotePerformanceListUseCase
    
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
        let trendingContentsLoadingState: Observable<Bool>
        let errorRelay: PublishRelay<any Error>
    }
    
    init(
        fetchBoxOfficeUseCase: some FetchBoxOfficeUseCase,
        fetchPerformanceListUseCase: some FetchRemotePerformanceListUseCase
    ) {
        self.fetchBoxOfficeUseCase = fetchBoxOfficeUseCase
        self.fetchPerformanceListUseCase = fetchPerformanceListUseCase
    }
    
    func transform(input: Input) -> Output {
        let topTenContents = BehaviorRelay<[BoxOfficeItem]>(value: [])
        let boxOfficeGenres = BehaviorRelay<[Constant.BoxOfficeGenre]>(
            value: Constant.BoxOfficeGenre.allCases.filter({ $0 != .unknown })
        )
        let trendingBoxOffice = BehaviorRelay<[BoxOfficeItem]>(value: [])
        let trendingContentsLoadingState = PublishRelay<Bool>()
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
                        trendingContentsLoadingState.accept(false)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        let genreSelected = input.itemSelected
            .filter { $0.section == 1 }
            .share()
        
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
                        trendingContentsLoadingState.accept(false)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        genreSelected
            .bind { _ in
                // 순서 주의!! 아래 두 흐름의 순서를 바꾸면 부자연스러워진다. -> 나중에 해결하기
                trendingContentsLoadingState.accept(true)
                trendingBoxOffice.accept([])
            }
            .disposed(by: disposeBag)
        
        return .init(
            topTenContents: topTenContents,
            boxOfficeGenres: boxOfficeGenres,
            trendingContents: trendingBoxOffice,
            trendingContentsLoadingState: trendingContentsLoadingState.asObservable(),
            errorRelay: errorRelay
        )
    }
    
}
