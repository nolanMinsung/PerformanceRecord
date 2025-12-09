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
    private(set) var relatedURL: URL?

    // --- UI Components ---
    private let scrollView = UIScrollView()
    private let mainStackView = UIStackView()
    
    private let nameLabel = UILabel()
    let linkButton = UIButton(type: .system)
    private let nameStackView = UIStackView()
    
    private let totalSeatsLabel = UILabel()
    private let addressLabel = UILabel()
    private let infoSectionStackView = UIStackView()
    
    private let mapView = MKMapView()
    
    private let amenitySection = AmenitySectionView()
    private let subVenuesStackView = UIStackView()
    private let subVenuesSectinoStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        scrollView.showsVerticalScrollIndicator = false
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
        
        setupInfoSection()
        setupMapSection()
        mainStackView.addArrangedSubview(amenitySection)
        setupSubVenueSection()
    }
    
    // 각 섹션별 UI 구성 함수들
    private func setupInfoSection() {
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let linkImage = UIImage(systemName: "link")
        linkButton.setImage(linkImage, for: .normal)
        linkButton.tintColor = .systemGray3
        linkButton.isHidden = true // Initially hidden
        linkButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nameStackView.axis = .horizontal
        nameStackView.spacing = 8
        nameStackView.alignment = .center
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(linkButton)
        
        totalSeatsLabel.font = .systemFont(ofSize: 16)
        totalSeatsLabel.textColor = .secondaryLabel
        addressLabel.font = .systemFont(ofSize: 16)
        
        infoSectionStackView.addArrangedSubview(nameStackView)
        infoSectionStackView.addArrangedSubview(totalSeatsLabel)
        infoSectionStackView.addArrangedSubview(addressLabel)
        
        infoSectionStackView.alignment = .leading
        infoSectionStackView.axis = .vertical
        infoSectionStackView.spacing = 8
    }
    
    private func setupMapSection() {
        mapView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        mapView.layer.cornerRadius = 12
    }
    
    private func setupSubVenueSection() {
        let titleLabel = UILabel()
        titleLabel.text = "공연장별 상세 정보"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        subVenuesStackView.axis = .vertical
        subVenuesStackView.spacing = 16
        
        subVenuesSectinoStackView.addArrangedSubview(titleLabel)
        subVenuesSectinoStackView.addArrangedSubview(subVenuesStackView)
        
        subVenuesSectinoStackView.axis = .vertical
        subVenuesSectinoStackView.spacing = 16
    }

    // 데이터 채우기
    public func configure(with facility: Facility) {
        nameLabel.text = facility.name
        
        guard let detail = facility.detail else {
            mainStackView.addArrangedSubview(infoSectionStackView)
            return
        }
        
        if let urlString = detail.relatedURL, let url = URL(string: urlString) {
            self.relatedURL = url
            self.linkButton.isHidden = false
        } else {
            self.linkButton.isHidden = true
        }
        
        totalSeatsLabel.text = "총 \(detail.totalSeatScale)석"
        addressLabel.text = detail.address
        mainStackView.addArrangedSubview(infoSectionStackView)
        
        // 지도 위치 설정
        if let latitude = detail.latitude, let longitude = detail.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = facility.name
            mapView.addAnnotation(annotation)
        }
        mainStackView.addArrangedSubview(mapView)
        
        // 편의시설
        amenitySection.configure(with: detail)
        mainStackView.addArrangedSubview(amenitySection)
        
        // 상세 공연장 정보
        subVenuesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        detail.subVenues.forEach { subVenue in
            let subVenueInfoView = SubVenueInfoView()
            subVenueInfoView.configure(with: subVenue)
            subVenuesStackView.addArrangedSubview(subVenueInfoView)
        }
        mainStackView.addArrangedSubview(subVenuesSectinoStackView)
    }
}
