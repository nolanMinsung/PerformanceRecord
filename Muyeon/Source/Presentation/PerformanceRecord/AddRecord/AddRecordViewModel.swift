//
//  AddRecordViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import RxSwift
import RxCocoa

final class AddRecordViewModel {
    
    struct Input {
        let viewedDate: Observable<Date>
        let ratingInput: Observable<Double>
        let reviewText: Observable<String>
        let addedImageData: Observable<[(ImageDataForSaving, UIImage)]>
        let deleteImageData: Observable<IndexPath>
        let saveButtonTapped: Observable<Void>
    }
    
    struct Output {
        let selectedImage: Observable<[(ImageDataForSaving, UIImage)]>
        let successCreateDiary: Observable<Void>
        let errorRelay: Observable<any Error>
    }
    
    private let performance: Performance
    private let createDiaryUseCase: any CreateDiaryUseCase
    private let diaryContent = PublishRelay<Record>()
    private let disposeBag = DisposeBag()
    
    init(performance: Performance, createDiaryUseCase: any CreateDiaryUseCase) {
        self.performance = performance
        self.createDiaryUseCase = createDiaryUseCase
    }
    
    func transform(input: Input) -> Output {
        let currentImageData = BehaviorRelay<[(ImageDataForSaving, UIImage)]>(value: [])
        let successCreateDiary = PublishRelay<Void>()
        let errorRelay = PublishRelay<any Error>()
        
        input.addedImageData
            .map { addedData in
                var currentData = currentImageData.value
                currentData.append(contentsOf: addedData)
                return currentData
            }
            .bind(to: currentImageData)
            .disposed(by: disposeBag)
        
        input.deleteImageData
            .map(\.item)
            .map { deletingIndex in
                var currentData = currentImageData.value
                currentData.remove(at: deletingIndex)
                return currentData
            }
            .bind(to: currentImageData)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            input.viewedDate,
            input.ratingInput,
            input.reviewText
        )
        .withUnretained(self)
        .map { owner, data in
            let (viewedDate, rating, reviewText) = data
            return Record(
                id: UUID().uuidString,
                performanceID: owner.performance.id,
                createdAt: .now,
                viewedAt: viewedDate,
                rating: rating,
                reviewText: reviewText,
                diaryImageUUIDs: []
            )
        }
        .bind(to: diaryContent)
        .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .withLatestFrom(diaryContent)
            .withLatestFrom(
                currentImageData,
                resultSelector: { diary, imageDataList in
                    return (diary, imageDataList)
                })
            .bind(
                with: self,
                onNext: { owner, data in
                    let (diary, imageDataList) = data
                    Task {
                        do {
                            try await owner.createDiaryUseCase.execute(diary: diary, imageData: imageDataList.map(\.0))
                            successCreateDiary.accept(())
                        } catch {
                            errorRelay.accept(error)
                        }
                    }
                })
            .disposed(by: disposeBag)
        
        return .init(
            selectedImage: currentImageData.asObservable(),
            successCreateDiary: successCreateDiary.asObservable(),
            errorRelay: errorRelay.asObservable()
        )
    }
    
}
