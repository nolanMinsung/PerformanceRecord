//
//  RecordDetailViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

class RecordDetailViewController: UIViewController {
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, RecordDetailUIModel>
    typealias CellRegistration = UICollectionView.CellRegistration<RecordCell, RecordDetailUIModel>
    typealias CellProvider = DiffableDataSource.CellProvider
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RecordDetailUIModel>
    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<RecordSectionHeaderView>
    
    
    // MARK: - UseCase
    private let fetchLocalPosterUseCase: any FetchLocalPosterUseCase
    private let fetchLocalPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase
    private let deleteRecordUseCase: any DeleteRecordUseCase
    
    // MARK: - Properties
    private let rootView = RecordDetailView()
    private var dataSource: DiffableDataSource!
    private let disposeBag = DisposeBag()
    
    private var performance: Performance
    private var recordUIModels: [RecordDetailUIModel] = []
    
    enum Section {
        case main
    }
    
    init(
        fetchLocalPosterUseCase: any FetchLocalPosterUseCase,
        fetchLocalPerformanceDetailUseCase: any FetchLocalPerformanceDetailUseCase,
        deleteRecordUseCase: any DeleteRecordUseCase,
        performance: Performance
    ) {
        self.fetchLocalPosterUseCase = fetchLocalPosterUseCase
        self.fetchLocalPerformanceDetailUseCase = fetchLocalPerformanceDetailUseCase
        self.deleteRecordUseCase = deleteRecordUseCase
        self.performance = performance
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureDataSource()
        bind()
        Task {
            try await self.updateContents()
        }
    }
    
    // MARK: - Setup
    private func configureUI() {
        self.view.backgroundColor = .systemGroupedBackground
        Task {
            do {
                let image = try await self.fetchLocalPosterUseCase.execute(performance: performance)
                self.rootView.configureHeader(with: performance, poster: image)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

// MARK: - UICollectionView Compositional Layout & Diffable DataSource
extension RecordDetailViewController {
    
    private func configureDataSource() {
        let cellRegistration = CellRegistration { [weak self] cell, indexPath, recordUIModel in
            guard let self else { return }
            cell.configure(with: recordUIModel)
            
            // 사진 셀 탭 핸들러 설정
            cell.onPhotoTapped = { [weak self] image in
                guard let self else { return }
                let photoVC = PhotoViewController(image: image)
                photoVC.modalPresentationStyle = .overFullScreen
                photoVC.modalTransitionStyle = .crossDissolve
                self.present(photoVC, animated: true)
            }
            
            // left Swipe 핸들러 설정
            cell.leftSwipeAction = { [weak self] in
                guard let self else { return }
                Task {
                    do {
                        try await self.deleteRecordUseCase.execute(record: recordUIModel.record)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        let cellProvider: CellProvider = { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }
        
        dataSource = DiffableDataSource(
            collectionView: rootView.collectionView,
            cellProvider: cellProvider
        )

        // 헤더 설정
        let headerRegistration = SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader,
            handler: { [weak self] (headerView, string, indexPath) in
                guard let self else { return }
                headerView.configure(count: self.recordUIModels.count)
            }
        )
        
        dataSource.supplementaryViewProvider = { [weak self] (view, kind, index) in
            guard let self else { fatalError() }
            return self.rootView.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }
    }
    
    private func bind() {
        DefaultRecordRepository.shared.recordUpdated
            .bind(with: self, onNext: { owner, _ in
                Task {
                    do {
                        try await owner.updateContents()
                    } catch {
                        print(error)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        rootView.addRecordButton.rx.tap
            .bind(
                with: self,
                onNext: { owner, _ in
                    let addRecordVC = AddRecordViewController(performance: owner.performance)
                    addRecordVC.modalPresentationStyle = .overFullScreen
                    addRecordVC.modalTransitionStyle = .crossDissolve
                    owner.present(addRecordVC, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func updateContents() async throws {
        let detailPerformance = try await self.fetchLocalPerformanceDetailUseCase.execute(performanceID: performance.id)
        self.performance = detailPerformance
        self.recordUIModels = try await withThrowingTaskGroup(
            of: RecordDetailUIModel.self,
            returning: [RecordDetailUIModel].self,
            body: { group in
                for record in detailPerformance.records {
                    group.addTask {
                        return try await RecordDetailUIModel(from: record)
                    }
                }
                var sortedRecordUIModel: [RecordDetailUIModel] = []
                for try await recordUIModel in group {
                    sortedRecordUIModel.append(recordUIModel)
                }
                return sortedRecordUIModel.sorted { $0.record.viewedAt > $1.record.viewedAt }
            }
        )
        self.applySnapshot(records: self.recordUIModels)
    }
    
    private func applySnapshot(records: [RecordDetailUIModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.reloadSections([.main])
        snapshot.appendItems(records)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
