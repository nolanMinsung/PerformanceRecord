//
//  SelectPerformanceViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/6/25.
//

import UIKit
import SnapKit

protocol SelectPerformanceDelegate: AnyObject {
    func didSelectPerformance(_ performance: Performance)
}

class SelectPerformanceViewController: UIViewController {
    
    private let rootView = SelectPerformanceView()
    
    weak var delegate: SelectPerformanceDelegate?
    private var performances: [Performance] = []
    private var selectedPerformance: Performance?

    init(performances: [Performance]) {
        self.performances = performances
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collectionView.dataSource = self
        rootView.collectionView.delegate = self
        rootView.addRecordButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        rootView.collectionView.reloadData()
    }
    
    @objc private func continueButtonTapped() {
        guard let selectedPerformance = selectedPerformance else { return }
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectPerformance(selectedPerformance)
        }
    }
    
}

extension SelectPerformanceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return performances.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PerformanceSelectionCell.identifier, for: indexPath) as? PerformanceSelectionCell else {
            fatalError()
        }
        cell.configure(with: performances[indexPath.row])
        return cell
    }
}


extension SelectPerformanceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPerformance  = performances[indexPath.row]
        let isUpcoming = Calendar.current.compare(.now, to: selectedPerformance.startDate, toGranularity: .day) == .orderedAscending
        if isUpcoming {
            self.selectedPerformance = nil
            rootView.addRecordButton.configuration?.title = "아직 시작하지 않은 공연은 기록을 남길 수 없어요."
            rootView.addRecordButton.configuration?.subtitle = "관람했던 공연으로 기록을 남겨보세요."
            rootView.addRecordButton.configuration?.titleAlignment = .center
            rootView.addRecordButton.isEnabled = false
        } else {
            self.selectedPerformance = selectedPerformance
            rootView.addRecordButton.configuration?.title = "공연 기록 남기기"
            rootView.addRecordButton.configuration?.subtitle = nil
            rootView.addRecordButton.configuration?.titleAlignment = .center
            rootView.addRecordButton.isEnabled = true
        }
    }
}
