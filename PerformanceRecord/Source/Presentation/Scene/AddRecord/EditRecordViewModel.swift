//
//  EditRecordViewModel.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/23/25.
//

import UIKit

import RxSwift
import RxCocoa

final class EditRecordViewModel {
    
    struct Input {
        let viewedDate: Observable<Date>
        let ratingInput: Observable<Double>
        let reviewText: Observable<String>
        let saveButtonTapped: Observable<Void>
        let dismissButtonTapped: Observable<Void>
    }
    
    struct Output {
        let initialSetting: Observable<Record>
        let selectedImage: Observable<[UIImage]>
        let successEditingRecord: Observable<Void>
        let shouldDismiss: Observable<Void>
        let errorRelay: Observable<any Error>
    }
    
    private let performance: Performance
    private let record: Record
    private let fetchRecordImagesUseCase: any FetchRecordImagesUseCase
    private let updateRecordUseCase: any UpdateRecordUseCase
    private let disposeBag = DisposeBag()
    
    init(
        performance: Performance,
        record: Record,
        fetchRecordImagesUseCase: any FetchRecordImagesUseCase,
        updateRecordUseCase: any UpdateRecordUseCase,
    ) {
        self.performance = performance
        self.record = record
        self.fetchRecordImagesUseCase = fetchRecordImagesUseCase
        self.updateRecordUseCase = updateRecordUseCase
    }
    
    func transform(input: Input) -> Output {
//        let currentImageData = BehaviorRelay<[ImageDataForSaving]>(value: [])
        let selectedImages = PublishRelay<[UIImage]>()
        let successCreateRecord = PublishRelay<Void>()
//        let saveButtonTapped = PublishRelay<Void>()
        let editingButtonTapped = PublishRelay<String>() // record ID 를 같이 전달
        let shouldDismissRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<any Error>()
        
        let initialSetting = Observable<Record>.just(record)
        
        Task {
            let images = try await self.fetchRecordImagesUseCase.execute(record: record)
            selectedImages.accept(images)
        }
        
        
//        let addedImageStream: Observable<[UIImage]> = currentImageData
//            .flatMap { array -> Observable<[UIImage]> in
//                return Observable<[UIImage]>.create { observer in
//                    do {
//                        let convertedArray = try array.map { dataForSaving in
//                            guard let image = UIImage(data: dataForSaving.data) else {
//                                throw AddRecordError.dataConvertingToImageFailed
//                            }
//                            return image
//                        }
//                        observer.onNext(convertedArray)
//                        return Disposables.create()
//                    } catch {
//                        observer.onError(error)
//                        return Disposables.create()
//                    }
//                }
//                .catch { error in
//                    errorRelay.accept(error)
//                    return Observable<[UIImage]>.never()
//                }
//            }
//            .bind(to: selectedImages)
//            .disposed(by: disposeBag)
        
//        input.deleteImageData
//            .map(\.item)
//            .map { deletingIndex in
//                var currentData = currentImageData.value
//                currentData.remove(at: deletingIndex)
//                return currentData
//            }
//            .bind(to: currentImageData)
//            .disposed(by: disposeBag)
        
        let recordDataStream = Observable.combineLatest(
            input.viewedDate,
            input.ratingInput,
            input.reviewText
        )
        
        let createdRecordDataStream = recordDataStream
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
            .bind(with: self, onNext: { owner, _ in
                editingButtonTapped.accept(owner.record.id)
//                switch owner.editingMode {
//                case .creatingNew:
//                    createdButtonTapped.accept(())
//                case .editing(recordUIModel: let recordUIModel):
//                }
            })
            .disposed(by: disposeBag)
        
        
//        saveButtonTapped
//            .withLatestFrom(createdRecordDataStream)
//            .withLatestFrom(
//                currentImageData,
//                resultSelector: { record, imageDataList in
//                    return (record, imageDataList)
//                })
//            .bind(
//                with: self,
//                onNext: { owner, data in
//                    let (record, imageDataList) = data
//                    Task {
//                        do {
//                            try await owner.createRecordUseCase.execute(record: record, imageData: imageDataList)
//                            successCreateRecord.accept(())
//                        } catch {
//                            errorRelay.accept(error)
//                        }
//                    }
//                })
//            .disposed(by: disposeBag)
        
        editingButtonTapped
            .withLatestFrom(recordDataStream, resultSelector: { ($0, $1) })
            .bind(
                with: self,
                onNext: { owner, data in
                    let (recordID, recordStream) = data
                    Task {
                        do {
                            try await owner.updateRecordUseCase.execute(
                                recordID: recordID,
                                viewedDate: recordStream.0,
                                rating: recordStream.1,
                                reviewText: recordStream.2
                            )
                        } catch {
                            errorRelay.accept(error)
                        }
                        shouldDismissRelay.accept(())
                    }
                }
            )
            .disposed(by: disposeBag)
        
        input.dismissButtonTapped
            .bind(to: shouldDismissRelay)
            .disposed(by: disposeBag)
        
        return .init(
            initialSetting: initialSetting,
            selectedImage: selectedImages.asObservable(),
            successEditingRecord: successCreateRecord.asObservable(),
            shouldDismiss: shouldDismissRelay.asObservable(),
            errorRelay: errorRelay.asObservable()
        )
    }
    
}
