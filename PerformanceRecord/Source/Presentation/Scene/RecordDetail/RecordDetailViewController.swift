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
    
    // MARK: - Properties
    
    private let rootView = RecordDetailView()
    private let viewModel: RecordDetailViewModel
    private let container: DIContainer
    private var dataSource: DiffableDataSource!
    private var recordUIModels: [RecordDetailUIModel] = []
    private let addRecordVCTransitioningDelegate = AddRecordViewTransitioningDelegate()
    
    private let disposeBag = DisposeBag()
    private let deleteRecord = PublishRelay<RecordDetailUIModel>()
    private let editRecord = PublishRelay<RecordDetailUIModel>()
    
    enum Section {
        case main
    }
    
    init(performance: Performance, container: DIContainer) {
        self.container = container
        self.viewModel = RecordDetailViewModel(
            fetchLocalPosterUseCase: container.resolve(type: FetchLocalPosterUseCase.self),
            fetchLocalPerformanceDetailUseCase: container.resolve(type: FetchLocalPerformanceDetailUseCase.self),
            deleteRecordUseCase: container.resolve(type: DeleteRecordUseCase.self),
            deletePerformanceUseCase: container.resolve(type: DeletePerformanceUseCase.self),
            performance: performance
        )
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
        
        self.view.backgroundColor = .systemGroupedBackground
        configureDataSource()
        bind()
        viewModel.recordsUpdateTrigger.accept(())
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
                deleteRecord.accept(recordUIModel)
            }
            
            cell.rightSwipeAction = { [weak self] in
                guard let self else { return }
                debugPrint("right swipe aciton detected")
                self.editRecord.accept(recordUIModel)
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
                let currentSnapshotCount = self.dataSource.snapshot(for: .main).items.count
                headerView.configure(count: currentSnapshotCount)
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
    
}
    

private extension RecordDetailViewController {
    
    func bind() {
        let input = RecordDetailViewModel.Input(
            addRecordTrigger: rootView.addRecordButton.rx.tap.asObservable(),
            editRecordAction: editRecord.asObservable(),
            recordDeleteAction: deleteRecord.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.performanceUIModel
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, performanceUIModel in
                    owner.rootView.configureHeader(with: performanceUIModel)
                }
            )
            .disposed(by: disposeBag)
        
        output.recordUIModels
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, recordDetailUIModel in
                owner.applySnapshot(records: recordDetailUIModel)
            })
            .disposed(by: disposeBag)
        
        output.addNewRecord
            .observe(on: MainScheduler.instance)
            .bind(
                with: self,
                onNext: { owner, performanceUIModel in
                    let addRecordVC = AddRecordViewController(
                        performance: performanceUIModel.performance,
                        container: owner.container,
                        image: performanceUIModel.poster
                    )
                    addRecordVC.modalPresentationStyle = .custom
                    addRecordVC.transitioningDelegate = owner.addRecordVCTransitioningDelegate
                    owner.present(addRecordVC, animated: true)
                }
            )
            .disposed(by: disposeBag)
        
        output.error
            .bind { error in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
        
    }
    
    func applySnapshot(records: [RecordDetailUIModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.reloadSections([.main])
        snapshot.appendItems(records)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
