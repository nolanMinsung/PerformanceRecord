//
//  DIContainer.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/18/25.
//

final class DIContainer {
    
    private var services: [String: Any] = [:]
    
    func register<Service>(type: Service.Type, _ factory: @escaping () -> Service) {
        let key = String(describing: type)
        services[key] = factory
    }
    
    func resolve<Service>(type: Service.Type) -> Service {
        let key = String(describing: type)
        
        guard let factory = services[key] as? () -> Service else {
            fatalError("\(key) is not registered.")
        }
        
        return factory()
    }
    
}
