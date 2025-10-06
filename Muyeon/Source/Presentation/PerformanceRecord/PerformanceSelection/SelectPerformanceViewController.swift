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

class SelectPerformanceViewController: ModalCardViewController {
    
    // View를 rootView 상수로 선언
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(46)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        rootView.collectionView.dataSource = self
        rootView.collectionView.delegate = self
        rootView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
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
        selectedPerformance = performances[indexPath.row]
        rootView.continueButton.isEnabled = true
    }
}
