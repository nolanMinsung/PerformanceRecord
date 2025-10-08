//
//  PerformanceRecordCell.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit

import SnapKit

// MARK: - '공연 기록' CollectionView Cell
class PerformanceRecordCell: UICollectionViewCell, ViewShrinkable {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let countLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .Main.third
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .Main.primary
        label.textAlignment = .center
        return label
    }()
    
    private let facilityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let genreTagLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .Main.third
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let genreTagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .Main.primary
        label.textAlignment = .center
        return label
    }()
    
    private let latestRecordZStack = UIView()
    
    private let latestRecordContentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let latestRecordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .leading
        return stackView
    }()
    
    private let latestRecordHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        return stackView
    }()
    
    private let lastViewedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .label
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let vStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                shrink(scale: 0.97)
            } else {
                restore()
            }
        }
    }
    
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
        countLabel.snp.contentCompressionResistanceHorizontalPriority = 800
        countLabelContainer.snp.contentCompressionResistanceHorizontalPriority = 800
        
        genreTagLabelContainer.addSubview(genreTagLabel)
        genreTagLabel.snp.contentCompressionResistanceHorizontalPriority = 800
        genreTagLabelContainer.snp.contentCompressionResistanceHorizontalPriority = 800
        
        latestRecordContentContainer.addSubview(latestRecordStackView)
        
        let zStack1 = UIView()
        let zStack2 = UIView()
        zStack1.backgroundColor = .systemGray4
        zStack2.backgroundColor = .systemGray5
        zStack1.layer.cornerRadius = 5
        zStack2.layer.cornerRadius = 5
        
        latestRecordZStack.addSubview(zStack1)
        latestRecordZStack.addSubview(zStack2)
        latestRecordZStack.addSubview(latestRecordContentContainer)
        
        containerView.addSubview(vStack)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        countLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(6)
        }
        genreTagLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.horizontalEdges.equalToSuperview().inset(6)
        }
        latestRecordStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        zStack1.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(zStack2).inset(6)
            make.verticalEdges.equalTo(zStack2).offset(8)
            make.bottom.equalToSuperview()
        }
        zStack2.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(latestRecordContentContainer).inset(8)
            make.verticalEdges.equalTo(latestRecordContentContainer).offset(8)
        }
        latestRecordContentContainer.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        vStack.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(performance: Performance, records: [Record]) {
        guard let latestRecord = records.sorted(by: { $0.viewedAt > $1.viewedAt }).first else { return }
        
        vStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        titleLabel.text = performance.name
        vStack.addArrangedSubview(titleLabel)
        
        facilityLabel.text = "\(performance.facilityFullName)"
        vStack.addArrangedSubview(facilityLabel)
        
        countLabel.text = "\(records.count)회 관람"
        genreTagLabel.text = performance.genre.description
        let spacer = UIView()
        spacer.isUserInteractionEnabled = false
        spacer.snp.contentHuggingHorizontalPriority = 100
        let performanceTagStack = UIStackView(arrangedSubviews: [genreTagLabelContainer, countLabelContainer, spacer])
        performanceTagStack.axis = .horizontal
        performanceTagStack.spacing = 6
        performanceTagStack.alignment = .fill
        vStack.addArrangedSubview(performanceTagStack)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        lastViewedDateLabel.text = "최근 관람: \(dateFormatter.string(from: latestRecord.viewedAt))"
        
        let starAttachment = NSTextAttachment()
        starAttachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow)
        let ratingString = NSMutableAttributedString(string: "")
        ratingString.append(NSAttributedString(attachment: starAttachment))
        ratingString.append(NSAttributedString(string: " \(latestRecord.rating)"))
        ratingLabel.attributedText = ratingString
        
        latestRecordHorizontalStack.addArrangedSubview(lastViewedDateLabel)
        latestRecordHorizontalStack.addArrangedSubview(ratingLabel)
        latestRecordStackView.addArrangedSubview(latestRecordHorizontalStack)
        
        if !latestRecord.reviewText.isEmpty {
            memoLabel.text = "💬 \(latestRecord.reviewText)"
            latestRecordStackView.addArrangedSubview(memoLabel)
        }
        
        vStack.addArrangedSubview(latestRecordZStack)
        vStack.setCustomSpacing(24, after: performanceTagStack)
    }
    
}
