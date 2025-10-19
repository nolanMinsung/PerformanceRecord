//
//  Assembler.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/19/25.
//

final class Assembler {
    let container: DIContainer
    
    init(assemblies: [any Assembly], container: DIContainer = DIContainer()) {
        self.container = container
        
        assemblies.forEach {
            $0.assemble(container: container)
        }
    }
}
