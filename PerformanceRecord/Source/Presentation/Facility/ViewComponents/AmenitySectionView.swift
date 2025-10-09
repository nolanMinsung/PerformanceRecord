//
//  AmenitySectionView.swift
//  Muyeon
//
//  Created by 김민성 on 9/30/25.
//

import UIKit

import SnapKit

/// 공연시설의 편의시설 아이콘들을 그리드 형태로 표시하는 컨테이너 뷰
class AmenitySectionView: UIView, BaseViewSettings {
    
    private let titleLabel = UILabel()
    private let gridStackView = UIStackView()
    private let mainStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUIProperties() {
        titleLabel.text = "편의시설"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        gridStackView.axis = .vertical
        gridStackView.spacing = 12
        gridStackView.distribution = .fillEqually
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
    }
    
    func setupHierarchy() {
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(gridStackView)
        addSubview(mainStackView)
    }
    
    func setupLayoutConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure(with detail: FacilityDetail) {
        // 기존 arrangedSubview들 제거
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let amenities: [(icon: String, label: String, isAvailable: Bool)] = [
            ("fork.knife", "레스토랑", detail.hasRestaurant),
            (detail.hasRestaurant ? "cup.and.saucer.fill" : "cup.and.saucer", "카페", detail.hasCafe),
            (detail.hasStore ? "storefront.fill": "storefront", "편의점", detail.hasStore), // SF Symbol에 편의점 아이콘이 없어 대체
            (detail.hasParkingLot ? "car.fill" : "car", "주차장", detail.hasParkingLot),
            (detail.hasNolibang ? "teddybear.fill" : "teddybear", "놀이방", detail.hasNolibang),
            (detail.hasSuyusil ? "heart.fill" : "heart", "수유실", detail.hasSuyusil),
            ("figure.roll", "장애인 주차", detail.hasParkingBarrier), // SF Symbol 통합 아이콘 사용
            ("figure.roll", "장애인 화장실", detail.hasRestroomBarrier),
            ("figure.roll", "장애인 경사로", detail.hasRunwayBarrier),
            (detail.hasElevatorBarrier ? "building.fill" : "building", "장애인 엘리베이터", detail.hasElevatorBarrier)
        ]

        let itemsPerRow = 5
        var currentRowStackView: UIStackView?

        for (index, amenity) in amenities.enumerated() {
            if index % itemsPerRow == 0 {
                currentRowStackView = UIStackView()
                currentRowStackView?.axis = .horizontal
                currentRowStackView?.spacing = 8
                currentRowStackView?.distribution = .fillEqually
                gridStackView.addArrangedSubview(currentRowStackView!)
            }
            
            let icon = UIImage(systemName: amenity.icon)
            let amenityView = AmenityIconView(icon: icon, text: amenity.label, isAvailable: amenity.isAvailable)
            currentRowStackView?.addArrangedSubview(amenityView)
        }
        
        // 마지막 줄 채우기
        if let lastRow = gridStackView.arrangedSubviews.last as? UIStackView,
           lastRow.arrangedSubviews.count < itemsPerRow {
            let neededDummies = itemsPerRow - lastRow.arrangedSubviews.count
            for _ in 0..<neededDummies {
                lastRow.addArrangedSubview(UIView())
            }
        }
    }
}
