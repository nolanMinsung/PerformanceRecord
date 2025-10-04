//
//  SearchPerformanceCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/1/25.
//

import UIKit
import SnapKit
import Kingfisher

final class SearchPerformanceCell: UICollectionViewCell {

    // MARK: - UI Components

    private let containerView = UIView()
    private let posterImageView = UIImageView()
    private let statusLabelContainer = UIView()
    private let statusLabel = UILabel()

    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let genreLabelContainer = UILabel()
    private let genreLabel = UILabel()
    
    private let facilityStackView = UIStackView()
    private let facilityIconImageView = UIImageView()
    private let facilityLabel = UILabel()
    
    private let dateStackView = UIStackView()
    private let dateIconImageView = UIImageView()
    private let dateLabel = UILabel()
    
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIProperties()
        setupHierarchy()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        titleLabel.text = nil
        genreLabel.text = nil
        facilityLabel.text = nil
        dateLabel.text = nil
    }

    // MARK: - Setup Methods

    private func setupUIProperties() {
        // Container View
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        // Poster Image
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 6

        // Status Label
        statusLabelContainer.backgroundColor = .Main.third
        statusLabelContainer.layer.cornerRadius = 4
        statusLabelContainer.clipsToBounds = true
        statusLabel.text = "진행중"
        statusLabel.textColor = .Main.primary
        statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
        statusLabel.textAlignment = .center
        
        // Title Label
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 2
        
        // Genre Label
        genreLabelContainer.backgroundColor = .lightGray
        genreLabelContainer.layer.cornerRadius = 8
        genreLabelContainer.clipsToBounds = true
        genreLabel.textColor = .white
        genreLabel.font = .systemFont(ofSize: 11, weight: .medium)
        genreLabel.textAlignment = .center
        
        // Facility
        configureIconAndLabelStack(
            facilityStackView,
            iconView: facilityIconImageView,
            iconName: "map",
            label: facilityLabel
        )
        
        // Date
        configureIconAndLabelStack(
            dateStackView,
            iconView: dateIconImageView,
            iconName: "calendar",
            label: dateLabel
        )
        
        // Main Text StackView
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading
    }

    private func setupHierarchy() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(posterImageView)
        containerView.addSubview(textStackView)
        posterImageView.addSubview(statusLabelContainer)
        statusLabelContainer.addSubview(statusLabel)
        genreLabelContainer.addSubview(genreLabel)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(genreLabelContainer)
        textStackView.addArrangedSubview(facilityStackView)
        textStackView.addArrangedSubview(dateStackView)
        
        facilityStackView.addArrangedSubview(facilityIconImageView)
        facilityStackView.addArrangedSubview(facilityLabel)
        
        dateStackView.addArrangedSubview(dateIconImageView)
        dateStackView.addArrangedSubview(dateLabel)
    }

    private func setupLayoutConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        posterImageView.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview().inset(8)
            make.width.equalTo(posterImageView.snp.height).multipliedBy(0.75)
        }
        
        statusLabelContainer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(4)
        }
        statusLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(3)
            make.horizontalEdges.equalToSuperview().inset(5)
        }

        textStackView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView).offset(5)
            make.leading.equalTo(posterImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
        }
        
        genreLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(7)
        }
        
        facilityIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
        
        dateIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
    }

    // MARK: - Configuration

    func configure(with performance: Performance) {
        let targetSize = posterImageView.bounds.size.applying(.init(scaleX: 0.5, y: 0.5))
        let processor = DownsamplingImageProcessor(size: targetSize)
        posterImageView.kf.setImage(
            with: URL(string: performance.posterURL),
            options: [.processor(processor), .scaleFactor(UIScreen.main.scale),]
        )
        
        titleLabel.text = performance.name
        
        genreLabel.text = "\(performance.genre.description)"
        
        facilityLabel.text = performance.facilityFullName
        
        // 날짜 포맷팅
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let startDateString = dateFormatter.string(from: performance.startDate)
        let endDateString = dateFormatter.string(from: performance.endDate)
        dateLabel.text = "\(startDateString) - \(endDateString)"
        
        // 상태에 따라 statusLabel 표시 여부 결정
        statusLabel.text = performance.state.description
    }
    
    // MARK: - Helper Methods
    
    private func configureIconAndLabelStack(_ stackView: UIStackView, iconView: UIImageView, iconName: String, label: UILabel) {
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
    }
}
