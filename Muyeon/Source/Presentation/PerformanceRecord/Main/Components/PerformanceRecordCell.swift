//
//  PerformanceRecordCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import SnapKit

// MARK: - '공연 기록' CollectionView Cell
class PerformanceRecordCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let countLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let facilityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let genreTagLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    private let genreTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let lastViewedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let seeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자세히 보기 →", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.tintColor = .label
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        countLabelContainer.addSubview(countLabel)
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, countLabelContainer])
        titleStack.spacing = 8
        titleStack.alignment = .center

        genreTagLabelContainer.addSubview(genreTagLabel)
        let facilityStack = UIStackView(arrangedSubviews: [facilityLabel, genreTagLabelContainer, ratingLabel])
        facilityStack.spacing = 8
        facilityStack.alignment = .center
        
        let vStack = UIStackView(arrangedSubviews: [
            titleStack,
            facilityStack,
            lastViewedDateLabel,
            memoLabel,
            seeMoreButton
        ])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.setCustomSpacing(12, after: facilityStack)
        vStack.alignment = .leading
        
        containerView.addSubview(vStack)
        
        containerView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(6)
        }
        
        genreTagLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(6)
        }
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure(performance: Performance, records: [Diary]) {
        guard let latestRecord = records.sorted(by: { $0.viewedAt > $1.viewedAt }).first else { return }

        titleLabel.text = performance.name
        countLabel.text = "\(records.count)회 관람"
        facilityLabel.text = "📍 \(performance.facilityFullName)"
        genreTagLabel.text = performance.genre.description
        
        let starAttachment = NSTextAttachment()
        starAttachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow)
        let ratingString = NSMutableAttributedString(string: "")
        ratingString.append(NSAttributedString(attachment: starAttachment))
        ratingString.append(NSAttributedString(string: " \(latestRecord.rating)"))
        ratingLabel.attributedText = ratingString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        lastViewedDateLabel.text = "📅 최근 관람: \(dateFormatter.string(from: latestRecord.viewedAt))"
        
        memoLabel.text = "💬 \(latestRecord.reviewText)"
    }
}
