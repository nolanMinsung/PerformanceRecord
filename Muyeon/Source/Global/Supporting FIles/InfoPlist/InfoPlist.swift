//
//  InfoPlist.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

struct InfoPlist {
    
    private static let infoPlist: [String: Any] = {
        guard let infoPlist = Bundle.main.infoDictionary else {
            fatalError("Info.plist not found")
        }
        return infoPlist
    }()
    
    static let apiKey: String = {
        guard let apiKey = infoPlist["APIKey"] as? String else {
            fatalError("Info.plist is not String")
        }
        return apiKey
    }()
    
}

