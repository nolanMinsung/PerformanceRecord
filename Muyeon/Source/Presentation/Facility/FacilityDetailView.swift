//
//  FacilityDetailView.swift
//  Muyeon
//
//  Created by 김민성 on 9/30/25.
//

import UIKit
import MapKit // 지도 사용

/// FacilityDetailViewController의 root view.
class FacilityDetailView: UIView {

    // --- UI Components ---
    private let scrollView = UIScrollView()
    private let mainStackView = UIStackView()
    
    private let nameLabel = UILabel()
    private let totalSeatsLabel = UILabel()
    private let addressLabel = UILabel()
    private let mapView = MKMapView()
    private let amenitySection = AmenitySectionView()
    private let subVenuesStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
        
        // --- Add components to stack view ---
        setupInfoSection()
        setupMapSection()
        setupActionButtons()
        mainStackView.addArrangedSubview(amenitySection)
        setupSubVenueSection()
    }
    
    // 각 섹션별 UI 구성 함수들
    private func setupInfoSection() {
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        totalSeatsLabel.font = .systemFont(ofSize: 16)
        totalSeatsLabel.textColor = .secondaryLabel
        addressLabel.font = .systemFont(ofSize: 16)

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, totalSeatsLabel, addressLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 8
        mainStackView.addArrangedSubview(infoStack)
    }
    
    private func setupMapSection() {
        mapView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        mapView.layer.cornerRadius = 12
        mainStackView.addArrangedSubview(mapView)
    }
    
    private func setupActionButtons() {
        let findRouteButton = UIButton(type: .system)
        findRouteButton.setTitle("길찾기", for: .normal)
        findRouteButton.backgroundColor = .label
        findRouteButton.setTitleColor(.systemBackground, for: .normal)
        findRouteButton.layer.cornerRadius = 8
        
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("공유하기", for: .normal)
        shareButton.layer.borderColor = UIColor.systemGray3.cgColor
        shareButton.layer.borderWidth = 1
        shareButton.setTitleColor(.label, for: .normal)
        shareButton.layer.cornerRadius = 8

        let buttonStack = UIStackView(arrangedSubviews: [findRouteButton, shareButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        mainStackView.addArrangedSubview(buttonStack)
    }
    
    private func setupSubVenueSection() {
        let titleLabel = UILabel()
        titleLabel.text = "공연장별 상세 정보"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        subVenuesStackView.axis = .vertical
        subVenuesStackView.spacing = 16
        
        let sectionStack = UIStackView(arrangedSubviews: [titleLabel, subVenuesStackView])
        sectionStack.axis = .vertical
        sectionStack.spacing = 16
        mainStackView.addArrangedSubview(sectionStack)
    }

    // 데이터 채우기
    public func configure(with facility: Facility) {
        nameLabel.text = facility.name
        
        if let detail = facility.detail {
            totalSeatsLabel.text = "총 \(detail.totalSeatScale)석"
            addressLabel.text = detail.address
            
            // 지도 위치 설정
            if let latitude = detail.latitude, let longitude = detail.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: false)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = facility.name
                mapView.addAnnotation(annotation)
                mapView.isScrollEnabled = false
            }
            
            // 편의시설
            amenitySection.configure(with: detail)
            
            // 상세 공연장 정보
            subVenuesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            detail.subVenues.forEach { subVenue in
                let subVenueInfoView = SubVenueInfoView()
                subVenueInfoView.configure(with: subVenue)
                subVenuesStackView.addArrangedSubview(subVenueInfoView)
            }
        }
        
    }
}
