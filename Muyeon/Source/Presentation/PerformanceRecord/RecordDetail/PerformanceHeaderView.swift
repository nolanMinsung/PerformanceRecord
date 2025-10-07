//
//  PerformanceHeaderView.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit

import SnapKit

class PerformanceHeaderView: UIView {

    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let venueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()


    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(venueLabel)
        infoStackView.addArrangedSubview(dateLabel)
        
        mainStackView.addArrangedSubview(posterImageView)
        mainStackView.addArrangedSubview(infoStackView)
        
        addSubview(mainStackView)
    }

    private func setupLayout() {
        posterImageView.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(posterImageView.snp.width).multipliedBy(1.4)
        }
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Public Methods
    func configure(with performance: Performance, poster: UIImage?) {
        titleLabel.text = performance.name
        venueLabel.text = performance.facilityFullName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        let startDateString = formatter.string(from: performance.startDate)
        let endDateString = formatter.string(from: performance.endDate)
        dateLabel.text = "\(startDateString) - \(endDateString)"
        posterImageView.image = poster
    }
    
}

