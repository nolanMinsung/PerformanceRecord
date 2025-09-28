//
//  BaseViewSettings.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import UIKit

protocol BaseViewSettings: UIView {
    func setupUIProperties()
    func setupHierarchy()
    func setupLayoutConstraints()
}
