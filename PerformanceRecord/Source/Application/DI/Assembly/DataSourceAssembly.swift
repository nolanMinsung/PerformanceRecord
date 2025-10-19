//
//  DataSourceAssembly.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/18/25.
//

struct DataSourceAssembly: Assembly {
    
    func assemble(container: DIContainer) {
        container.register(
            type: LocalImageDataSource.self,
            { return DefaultLocalImageDataSource.shared }
        )
        
        container.register(
            type: RemoteImageDataSource.self,
            { return DefaultRemoteImageDataSource.shared }
        )
    }
    
}
