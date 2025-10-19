//
//  NetworkMonitor.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/19/25.
//

import Foundation
import Network

import RxSwift
import RxRelay

final class NetworkMonitor {
    
    //MARK: static Properties
    
    static let shared = NetworkMonitor()
    
    //MARK: - Properties
    
    private var disposeBag = DisposeBag()
    
    private let networkMonitor = NWPathMonitor()
    private var pathInterfaceChangedRelay = PublishRelay<Bool>()
    private var networkConnectionChangedRelay = PublishRelay<Bool>()
    
    var pathInterfaceChanged: Observable<Bool> { return pathInterfaceChangedRelay.asObservable() }
    var networkConnectionChanged: Observable<Bool> { return networkConnectionChangedRelay.asObservable() }
    
    //MARK: - Life Cycle
    
    private init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.pathInterfaceChangedRelay.accept(path.status == .satisfied)
        }
        
        pathInterfaceChangedRelay
            .distinctUntilChanged()
//            .debounce(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .bind(to: networkConnectionChangedRelay)
            .disposed(by: disposeBag)
        
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
}

