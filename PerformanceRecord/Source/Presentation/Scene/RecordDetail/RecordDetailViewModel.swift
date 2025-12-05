//
//  RecordDetailViewModel.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/17/25.
//

import Foundation

import RxSwift
import RxCocoa

final class RecordDetailViewModel {
    
    struct Input {
        let backButtonTrigger: Observable<Void>
        let addRecordTrigger: Observable<Void>
        let editRecordAction: Observable<RecordDetailUIModel>
        let recordDeleteAction: Observable<RecordDetailUIModel>
    }
    
    struct Output {
        let pop: Observable<Void>
        let performanceUIModel: Observable<RecordDetailPerformanceUIModel>
        let recordUIModels: Observable<[RecordDetailUIModel]>
        let addNewRecord: Observable<RecordDetailPerformanceUIModel>
        let editRecord: Observable<(performanceUIModel: RecordDetailPerformanceUIModel, recordUIModel: RecordDetailUIModel)>
        let error: Observable<any Error>
    }
    
    // MARK: - UseCase
    private let fetchLocalPosterUseCase: any FetchLocalPosterUseCase
    private let fetchLocalPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase
    private let deleteRecordUseCase: any DeleteRecordUseCase
    private let deletePerformanceUseCase: any DeletePerformanceUseCase
    
    @UserDefault(key: .likePerformanceIDs, defaultValue: [])
    var likePerformanceIDs: [String]
    
    private var performance: Performance
//    private var recordUIModels: [RecordDetailUIModel] = []
    
    let recordsUpdateTrigger = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(
        fetchLocalPosterUseCase: any FetchLocalPosterUseCase,
        fetchLocalPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase,
        deleteRecordUseCase: any DeleteRecordUseCase,
        deletePerformanceUseCase: any DeletePerformanceUseCase,
        performance: Performance,
    ) {
        self.fetchLocalPosterUseCase = fetchLocalPosterUseCase
        self.fetchLocalPerformanceDetailUseCase = fetchLocalPerformanceDetailUseCase
        self.deleteRecordUseCase = deleteRecordUseCase
        self.deletePerformanceUseCase = deletePerformanceUseCase
        self.performance = performance
    }
    
    
    func transform(input: Input) -> Output {
        let popRelay = PublishRelay<Void>()
        let performanceUIModelRelay = PublishRelay<RecordDetailPerformanceUIModel>()
        let recordUIModelsRelay = BehaviorRelay<[RecordDetailUIModel]>(value: [])
        let addNewRecordRelay = PublishRelay<RecordDetailPerformanceUIModel>()
        let editRecordRelay = PublishRelay<(performanceUIModel: RecordDetailPerformanceUIModel, recordUIModel: RecordDetailUIModel)>()
        let errorRelay = PublishRelay<any Error>()
        
        DefaultRecordRepository.shared.recordUpdated
            .bind(to: recordsUpdateTrigger)
            .disposed(by: disposeBag)
        
        input.backButtonTrigger
            .bind(to: popRelay)
            .disposed(by: disposeBag)
        
        recordsUpdateTrigger
            .bind(with: self, onNext: { owner, _ in
                Task {
                    do {
                        owner.performance = try await owner.fetchLocalPerformanceDetailUseCase.execute(
                            performanceID: owner.performance.id
                        )
                        let updatedRecordUIModels = try await withThrowingTaskGroup(
                            of: RecordDetailUIModel.self,
                            returning: [RecordDetailUIModel].self,
                            body: { group in
                                for record in owner.performance.records {
                                    group.addTask {
                                        return try await RecordDetailUIModel(from: record)
                                    }
                                }
                                var sortedRecordUIModel: [RecordDetailUIModel] = []
                                for try await recordUIModel in group {
                                    sortedRecordUIModel.append(recordUIModel)
                                }
                                return sortedRecordUIModel.sorted { $0.record.viewedAt > $1.record.viewedAt }
                            }
                        )
                        recordUIModelsRelay.accept(updatedRecordUIModels)
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.addRecordTrigger
            .withLatestFrom(performanceUIModelRelay)
            .bind { performanceUIModel in
                addNewRecordRelay.accept(performanceUIModel)
            }
            .disposed(by: disposeBag)
        
        input.editRecordAction
            .withLatestFrom(performanceUIModelRelay, resultSelector: { return ($1, $0) })
            .bind(to: editRecordRelay)
            .disposed(by: disposeBag)
        
        input.recordDeleteAction
            .bind(with: self, onNext: { owner, recordDetailUIModel in
                Task {
                    do {
                        try await owner.deleteRecordUseCase.execute(record: recordDetailUIModel.record)
                        let updatedPerformanceDetail = try await owner.fetchLocalPerformanceDetailUseCase.execute(
                            performanceID: owner.performance.id
                        )
                        
                        let performanceHasNoRecords: Bool = updatedPerformanceDetail.records.isEmpty
                        let performanceLikeStatus: Bool = owner.likePerformanceIDs.contains(owner.performance.id)
                        if performanceHasNoRecords && !performanceLikeStatus {
                            debugPrint("로컬 Performance에 기록이 없고, 좋아요 목록에도 없으므로 로컬에 저장된 Performance 데이터를 삭제합니다.")
                            try? await owner.deletePerformanceUseCase.execute(performanceID: owner.performance.id)
                        }
                    } catch {
                        errorRelay.accept(error)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        Task {
            let performancePoster = try await self.fetchLocalPosterUseCase.execute(performance: performance)
            let generatedPerformanceUIModel = RecordDetailPerformanceUIModel(performance: performance, poster: performancePoster)
            performanceUIModelRelay.accept(generatedPerformanceUIModel)
        }
        
        return .init(
            pop: popRelay.asObservable(),
            performanceUIModel: performanceUIModelRelay.asObservable(),
            recordUIModels: recordUIModelsRelay.asObservable(),
            addNewRecord: addNewRecordRelay.asObservable(),
            editRecord: editRecordRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
    
}
