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
    
    func convertUpdateToDate() -> Date? {
        
        // 밀리초를 포함하는 첫 번째 형식 (가장 긴 형식)
        let formatterWithMilliseconds = DateFormatter()
        formatterWithMilliseconds.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        formatterWithMilliseconds.locale = Locale(identifier: "en_US_POSIX") // 포맷팅 표준화를 위해 설정함.
        
        if let date = formatterWithMilliseconds.date(from: self) {
            return date
        }
        
        // 초까지의 일반 형식 (두 번째 형식)
        let formatterWithoutMilliseconds = DateFormatter()
        formatterWithoutMilliseconds.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatterWithoutMilliseconds.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatterWithoutMilliseconds.date(from: self) {
            return date
        }
        
        // 두 형식 모두 실패한 경우
        return nil
    }
    
    func parsePlaceAndDetail() -> (place: String, detail: String)? {
        guard let closeParenIndex = self.lastIndex(of: ")") else {
            return nil
        }
        
        // 마지막 닫는 괄호 기준으로 짝이 되는 여는 괄호 탐색
        var balance = 0
        var openParenIndex: String.Index? = nil
        var currentIndex = closeParenIndex
        
        while currentIndex > self.startIndex {
            currentIndex = self.index(before: currentIndex)
            let char = self[currentIndex]
            
            if char == ")" {
                balance += 1
            } else if char == "(" {
                if balance == 0 {
                    openParenIndex = currentIndex
                    break
                } else {
                    balance -= 1
                }
            }
        }
        
        guard let openIndex = openParenIndex else {
            return nil
        }
        
        // 장소 이름 (괄호 앞 공백 제거)
        let placePart = self[..<openIndex].trimmingCharacters(in: .whitespaces)
        // 상세 장소 (괄호 안 문자열만)
        let detailPart = self[self.index(after: openIndex)..<closeParenIndex]
        
        return (String(placePart), String(detailPart))
    }
    
}
