//
//  Date+.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/27/25.
//

import Foundation

extension Date {
    
    func addingDay(_ day: Int) -> Date {
        let timeToAdd = TimeInterval(day*3600*24)
        return addingTimeInterval(timeToAdd)
    }
    
}
