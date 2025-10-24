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
        let recordImage: Observable<[UIImage]>
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
        let recordImages = BehaviorRelay<[UIImage]>(value: [])
        let successCreateRecord = PublishRelay<Void>()
//        let saveButtonTapped = PublishRelay<Void>()
        let editingButtonTapped = PublishRelay<String>() // record ID 를 같이 전달
        let shouldDismissRelay = PublishRelay<Void>()
        let errorRelay = PublishRelay<any Error>()
        
        let initialSetting = Observable<Record>.just(record)
        
        Task {
            let images = try await self.fetchRecordImagesUseCase.execute(record: record)
            recordImages.accept(images)
        }
        
        let recordDataStream = Observable.combineLatest(
            input.viewedDate,
            input.ratingInput,
            input.reviewText
        )
        
        input.saveButtonTapped
            .bind(with: self, onNext: { owner, _ in
                editingButtonTapped.accept(owner.record.id)
            })
            .disposed(by: disposeBag)
        
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
            recordImage: recordImages.asObservable(),
            successEditingRecord: successCreateRecord.asObservable(),
            shouldDismiss: shouldDismissRelay.asObservable(),
            errorRelay: errorRelay.asObservable()
        )
    }
    
}
