//
//  RepositoryAssembly.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/18/25.
//

struct RepositoryAssembly: Assembly {
    
    func assemble(container: DIContainer) {
        container.register(
            type: ImageRepository.self,
            { return DefaultImageRepository.shared }
        )
        
        container.register(
            type: PerformanceRepository.self,
            { return DefaultPerformanceRepository.shared }
        )
        
        container.register(
            type: RecordRepository.self,
            { return DefaultRecordRepository.shared }
        )
    }
    
}
