//
//  UserDefault.swift
//  Muyeon
//
//  Created by 김민성 on 10/4/25.
//

import Foundation

@propertyWrapper struct UserDefault<T> {
    
    enum UserDefaultsKey: String {
        /// `[String]` 타입
        case likePerformanceIDs
    }
    
    let key: UserDefaultsKey
    let defaultValue: T
    
    var wrappedValue: T {
        get { return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
    }
    
}
