//
//  Date+.swift
//  Muyeon
//
//  Created by 김민성 on 9/27/25.
//

import Foundation

extension Date {
    
    func addingDay(_ day: Int) -> Date {
        let timeToAdd = TimeInterval(day*3600*24)
        return addingTimeInterval(timeToAdd)
    }
    
    /// 그레고리안력 기준
    var isThisYear: Bool {
        let calendar = Calendar(identifier: .gregorian)
        let targetYear = calendar.component(.year, from: self)
        let currentYear = calendar.component(.year, from: Date())
        return targetYear == currentYear
    }
    
}
