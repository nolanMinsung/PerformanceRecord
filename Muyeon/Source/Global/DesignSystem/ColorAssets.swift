//
//  ColorAssets.swift
//  MSClassProject
//
//  Created by 김민성 on 9/5/25.
//

import UIKit

extension UIColor {
    
    enum Main {
        static let primary = UIColor(hexLight: "0065F8")
        static let secondary = UIColor(hexLight: "87C4FF")
        static let third = UIColor(hexLight: "dee7fa")
    }
    
    
    enum Gray {
        static let gray50 = UIColor(hexLight: "F9FAFB")    // 가장 밝은 배경
        static let gray100 = UIColor(hexLight: "F3F4F6")    // 매우 밝은 배경
        static let gray200 = UIColor(hexLight: "E5E7EB")    // 경계선(Borders)이나 구분선
        static let gray300 = UIColor(hexLight: "D1D5DB")    // 일반적인 구분선
        static let gray400 = UIColor(hexLight: "9CA3AF")    // 비활성화(Disabled)된 요소
        static let gray500 = UIColor(hexLight: "6B7280")    // 중간 회색 (기준)
        static let gray600 = UIColor(hexLight: "4B5563")    // 밝은 텍스트나 아이콘
        static let gray700 = UIColor(hexLight: "374151")    // 일반적인 텍스트
        static let gray800 = UIColor(hexLight: "1F2937")    // 어두운 텍스트나 배경
        static let gray900 = UIColor(hexLight: "111827")    // 가장 어두운 배경/텍스트
    }
    
}
