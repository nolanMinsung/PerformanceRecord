//
//  String+DesignSystem.swift
//  MSClassProject
//
//  Created by 김민성 on 9/5/25.
//

import Foundation

extension String {
    
    /// 문자열이 유효한 컬러 hex code 형식인지 판단. (#없는 문자열)
    func isValidColorHexDigits() -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "^([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$") else { return false }
        let range = NSRange(location: 0, length: self.count)
        let resultLength = regex.rangeOfFirstMatch(in: self, range: range).length
        // 간혹 hexCode가 8자리로 오는 경우도 있다.(앞의 두 자리가 alpha)
        return (resultLength == 6 || resultLength == 8)
    }
    
}
