//
//  ShrinkableButton.swift
//  Muyeon
//
//  Created by 김민성 on 10/9/25.
//

import UIKit

class ShrinkableButton: UIButton, ViewShrinkable {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                shrink(scale: 0.95)
            } else {
                restore()
            }
        }
    }
    
}
