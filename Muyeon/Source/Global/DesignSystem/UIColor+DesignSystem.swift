//
//  UIColor+DesignSystem.swift
//  MSClassProject
//
//  Created by 김민성 on 9/5/25.
//

import UIKit

extension UIColor {
    
    /// hex code 문자열로 UIColor를 생성.
    /// - Parameter hexCode: hex code. #98FB98 혹은 8E8E8E 같은 형식으로 입력
    ///
    /// invalid한 hex code 입력 시 `fatalError` 발생(추후 개선 필요)
    convenience init(hexCode: String) {
        var hextString: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hextString.hasPrefix("#") {
            hextString.removeFirst()
        }
        
        guard hextString.isValidColorHexDigits() else {
            // fatalError 말고, 임의로 hexCode를 채워 넣고, 경고를 주는 방식이 더 적절할 듯..
            // (서버에서 동적으로 hexCode를 받아올 수도 있기 때문)
            fatalError("Invalid hex code: \(hextString)")
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hextString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }
    
}


extension UIColor {
    
    convenience init(hexLight: String, hexDark: String? = nil) {
        let lightColor = UIColor(hexCode: hexLight)
        let darkColor = UIColor(hexCode: hexDark ?? hexLight)
        
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:  return lightColor
            case .dark:                 return darkColor
            @unknown default:           return lightColor
            }
        }
    }
    
}
