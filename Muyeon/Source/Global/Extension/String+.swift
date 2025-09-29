//
//  String+.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import Foundation

extension String {
    
    func convertURLToHTTPS() -> String {
        let httpPrefix = "http://"
        let httpsPrefix = "https://"
        guard hasPrefix(httpPrefix) else { return self }
        return replacingOccurrences(of: httpPrefix, with: httpsPrefix, options: .anchored)
    }
    
}
