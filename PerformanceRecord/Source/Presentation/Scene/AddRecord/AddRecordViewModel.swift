//
//  AddRecordViewModel.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import PhotosUI
import RxSwift
import RxCocoa

final class AddRecordViewModel {
    
    struct Input {
        let viewedDate: Observable<Date>
        let ratingInput: Observable<Double>
        let reviewText: Observable<String>
        let phPickerSelected: Observable<[PHPickerResult]>
        let deleteImageData: Observable<IndexPath>
        let saveButtonTapped: Observable<Void>
        let dismissButtonTapped: Observable<Void>
    }
    
    struct Output {
        let selectedImage: Observable<[UIImage]>
        let successCreateRecord: Observable<Void>
        let shouldDismiss: Observable<Void>
        let errorRelay: Observable<any Error>
    }
    
    private let performance: Performance
    private let createRecordUseCase: any CreateRecordUseCase
    private let processUserSelectedImageUseCase: any ProcessUserSelectedImageUseCase
    private let disposeBag = DisposeBag()
    
    init(
        performance: Performance,
        createRecordUseCase: any CreateRecordUseCase,
        processUserSelectedImageUseCase: any ProcessUserSelectedImageUseCase
    ) {
        self.performance = performance
        self.createRecordUseCase = createRecordUseCase
        self.processUserSelectedImageUseCase = processUserSelectedImageUseCase
    }
    
    func transform(input: Input) -> Output {
        let currentImageData = BehaviorRelay<[ImageDataForSaving]>(value: [])
        let successCreateRecord = PublishRelay<Void>()
        let errorRelay = PublishRelay<any Error>()
        
        input.phPickerSelected
            .map { pickerResult in
                let imageProviderArray = pickerResult.map {
                    PHPickerResultAdapter(phPickerResult: $0)
                }
                return imageProviderArray
            }
            .bind { imageProviderArray in
                Task {
                    do {
                        let addedImageData = try await self.processUserSelectedImageUseCase.execute(with: imageProviderArray)
                        var currentImageDataValue = currentImageData.value
                        currentImageDataValue.append(contentsOf: addedImageData)
                        currentImageData.accept(currentImageDataValue)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        let addedImageStream: Observable<[UIImage]> = currentImageData
            .flatMap { array -> Observable<[UIImage]> in
                return Observable<[UIImage]>.create { observer in
                    do {
                        let convertedArray = try array.map { dataForSaving in
                            guard let image = UIImage(data: dataForSaving.data) else {
                                throw AddRecordError.dataConvertingToImageFailed
                            }
                            return image
                        }
                        observer.onNext(convertedArray)
                        return Disposables.create()
                    } catch {
                        observer.onError(error)
                        return Disposables.create()
                    }
                }
                .catch { error in
                    errorRelay.accept(error)
                    return Observable<[UIImage]>.never()
                }
            }
        
        input.deleteImageData
            .map(\.item)
            .map { deletingIndex in
                var currentData = currentImageData.value
                currentData.remove(at: deletingIndex)
                return currentData
            }
            .bind(to: currentImageData)
            .disposed(by: disposeBag)
        
        let recordDataStream = Observable.combineLatest(
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
                recordImageUUIDs: []
            )
        }
        
        input.saveButtonTapped
            .withLatestFrom(recordDataStream)
            .withLatestFrom(
                currentImageData,
                resultSelector: { record, imageDataList in
                    return (record, imageDataList)
                })
            .bind(
                with: self,
                onNext: { owner, data in
                    let (record, imageDataList) = data
                    Task {
                        do {
                            try await owner.createRecordUseCase.execute(record: record, imageData: imageDataList)
                            successCreateRecord.accept(())
                        } catch {
                            errorRelay.accept(error)
                        }
                    }
                })
            .disposed(by: disposeBag)
        
        return .init(
            selectedImage: addedImageStream,
            successCreateRecord: successCreateRecord.asObservable(),
            shouldDismiss: input.dismissButtonTapped.asObservable(),
            errorRelay: errorRelay.asObservable()
        )
    }
    
}
