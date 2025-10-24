//
//  BubbleButton.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/19/25.
//

import UIKit

final class BubbleButton: UIButton, ViewShrinkable {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                shrink(duration: 1.0, scale: 0.95, isBubble: true)
            } else {
                restore(duration: 1.0, isBubble: true)
            }
        }
    }
    
}
