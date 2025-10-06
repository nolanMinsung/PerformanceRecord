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
        
        setupActions()
    }
    
    // View의 컴포넌트와 Controller의 로직 연결
    private func setupActions() {
        rootView.tableView.dataSource = self
        rootView.tableView.delegate = self
        rootView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        guard let selectedPerformance = selectedPerformance else { return }
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectPerformance(selectedPerformance)
        }
    }
}

extension SelectPerformanceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return performances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PerformanceSelectionCell.identifier, for: indexPath) as? PerformanceSelectionCell else {
            return UITableViewCell()
        }
        cell.configure(with: performances[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}


extension SelectPerformanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPerformance = performances[indexPath.row]
        rootView.continueButton.isEnabled = true
    }
}
