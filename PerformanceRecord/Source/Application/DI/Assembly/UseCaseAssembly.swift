//
//  UseCaseAssembly.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/18/25.
//

struct UseCaseAssembly: Assembly {
    
    func assemble(container: DIContainer) {
        let imageRepository = container.resolve(type: ImageRepository.self)
        let performanceRepository = container.resolve(type: PerformanceRepository.self)
        let recordRepository = container.resolve(type: RecordRepository.self)
        let imageDataSource = container.resolve(type: LocalImageDataSource.self)
        
        container.register(
            type: CreateRecordUseCase.self,
            {
                return DefaultCreateRecordUseCase(
                    performanceRepository: performanceRepository,
                    recordRepository: recordRepository,
                )
            }
        )
        
        container.register(
            type: DeletePerformanceUseCase.self,
            { return DefaultDeletePerformanceUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: DeleteRecordUseCase.self,
            { return DefaultDeleteRecordUseCase(recordRepository: recordRepository) }
        )
        
        container.register(
            type: FetchAllRecordsUseCase.self,
            { return DefaultFetchAllRecordsUseCase(recordRepository: recordRepository) }
        )
        
        container.register(
            type: FetchBoxOfficeUseCase.self,
            { return DefaultFetchBoxOfficeUseCase() }
        )
        
        container.register(
            type: FetchFacilityDetailUseCase.self,
            { return DefaultFetchFacilityDetailUseCase() }
        )
        
        container.register(
            type: FetchFacilityListUseCase.self,
            { return DefaultFetchFacilityListUseCase() }
        )
        
        container.register(
            type: FetchLikePerformanceListUseCase.self,
            { return DefaultFetchLikePerformanceListUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: FetchLocalPerformanceDetailUseCase.self,
            { return DefaultFetchLocalPerformanceDetailUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: FetchLocalPerformanceListUseCase.self,
            { return DefaultFetchLocalPerformanceListUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: FetchLocalPosterUseCase.self,
            { return DefaultFetchLocalPosterUseCase(imageRepository: imageRepository) }
        )
        
        container.register(
            type: FetchMostViewedPerformanceUseCase.self,
            { return DefaultFetchMostViewedPerformanceUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: FetchRecordImagesUseCase.self,
            { return DefaultFetchRecordImagesUseCase(imageDataSource: imageDataSource) }
        )
        
        container.register(
            type: FetchRecordsUseCase.self,
            { return DefaultFetchRecordsUseCase(recordRepository: recordRepository) }
        )
        
        container.register(
            type: FetchRemotePerformanceDetailUseCase.self,
            { return DefaultFetchRemotePerformanceDetailUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: FetchRemotePerformanceListUseCase.self,
            { return DefaultFetchRemotePerformanceListUseCase() }
        )
        
        container.register(
            type: ProcessUserSelectedImageUseCase.self,
            { return DefaultProcessUserSelectedImageUseCase() }
        )
        
        container.register(
            type: SavePerformanceUseCase.self,
            { return DefaultSavePerformanceUseCase(repository: performanceRepository) }
        )
        
        container.register(
            type: TogglePerformanceLikeUseCase.self,
            { return DefaultTogglePerformanceLikeUseCase(performanceRepository: performanceRepository) }
        )
        
        container.register(
            type: UpdateRecordUseCase.self,
            { return DefaultUpdateRecordUseCase(recordRepository: recordRepository) }
        )
    }
    
}
