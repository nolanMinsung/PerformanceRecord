//
//  HomeUIModel.swift
//  Muyeon
//
//  Created by 김민성 on 9/29/25.
//

import Foundation

enum HomeUIModel: Hashable {
    case topTen(model: BoxOfficeItem)
    case genre(model: Constant.BoxOfficeGenre)
    case trending(model: BoxOfficeItem)
}
