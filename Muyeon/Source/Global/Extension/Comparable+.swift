//
//  Comparable+.swift
//  XMLParserDemo
//
//  Created by 김민성 on 9/26/25.
//

import Foundation

extension Comparable {
    func clipped(lowerBound: Self, upperBound: Self) -> Self {
        return max(lowerBound, min(self, upperBound))
    }
}
