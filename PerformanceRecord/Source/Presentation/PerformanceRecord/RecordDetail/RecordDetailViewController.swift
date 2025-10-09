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
    
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Record>
    typealias CellProvider = DiffableDataSource.CellProvider
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
    private var records: [Record] = []
    
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
//        setupData()
        configureUI()
        configureDataSource()
//        applySnapshot(records: records)
        bind()
        Task {
            try await self.updateContents()
        }
    }
    
    private func setupData() {
        self.records = performance.records.sorted(by: { $0.viewedAt > $1.viewedAt })
    }
    
    // MARK: - Setup
    private func configureUI() {
        self.view.backgroundColor = .systemGroupedBackground
        Task {
            do {
                let image = try await fetchLocalPosterUseCase.execute(performance: performance)
                rootView.configureHeader(with: performance, poster: image)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // 예시 데이터 설정
    private func setupSampleData() {
        // React 코드의 샘플 데이터를 Swift 모델로 변환
        let p1 = Performance(
            id: "perf_1",
            name: "레미제라블",
            startDate: .now.addingDay(-30),
            endDate: .now.addingDay(-4),
            facilityFullName: "샤롯데씨어터",
            posterURL: "",
            posterImageID: nil,
            area: .seoul,
            genre: .musical,
            openRun: false,
            state: .completed,
            records: [],
            detail: nil
        )
        performance = p1
//        let p2 = Performance(
//            id: "perf_2",
//            name: "BTS WORLD TOUR",
//            startDate: .now.addingDay(-10),
//            endDate: .now.addingDay(-1),
//            facilityFullName: "잠실종합운동장",
//            posterURL: "",
//            area: .seoul,
//            genre: .popularMusic,
//            openRun: false,
//            state: .completed,
//            detail: nil
//        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        records = [
            Record(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-06-20")!,
                rating: 4.5,
                reviewText: "",
                recordImageUUIDs: ["0"]
            ),
            Record(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-10-01")!,
                rating: 5.0,
                reviewText: "평생 잊지 못할 경험! 아미들과 함께 떼창하는 순간이 최고였다. 무대 연출도 정말 화려했다.",
                recordImageUUIDs: []
            ),
            Record(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-03-15")!,
                rating: 5.0,
                reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.",
                recordImageUUIDs: ["0", "1", "2", "3", "4"]
            ),
            Record(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-03-15")!,
                rating: 5.0,
                reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.",
                recordImageUUIDs: ["0", "1", "2", "3", "4"]
            )
        ]
    }
}

// MARK: - UICollectionView Compositional Layout & Diffable DataSource
extension RecordDetailViewController {
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<RecordCell, Record> { cell, indexPath, record in
            cell.configure(with: record)
            // 사진 셀 탭 핸들러 설정
            cell.onPhotoTapped = { [weak self] image in
                guard let self else { return }
                
                let photoVC = PhotoViewController(image: image)
                photoVC.modalPresentationStyle = .overFullScreen
                photoVC.modalTransitionStyle = .crossDissolve
                self.present(photoVC, animated: true)
            }
            
            cell.leftSwipeAction = { [weak self] in
                guard let self else { return }
                Task {
                    do {
                        try await self.deleteRecordUseCase.execute(record: record)
//                        let detailPerformance = try await self.fetchLocalPerformanceDetailUseCase.execute(performanceID: self.performance.id)
//                        self.applySnapshot(records: detailPerformance.records.sorted(by: { $0.viewedAt > $1.viewedAt }))
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
            elementKind: UICollectionView.elementKindSectionHeader
        ) {
            (headerView, string, indexPath) in
            headerView.configure(count: self.records.count)
        }

        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.rootView.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }
    }
    
    private func bind() {
        DefaultRecordRepository.shared.recordUpdated
            .bind(onNext: { [weak self] _ in
                guard let self else { return }
                Task {
                    try await self.updateContents()
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
        self.records = detailPerformance.records.sorted(by: { $0.viewedAt > $1.viewedAt })
        self.applySnapshot(records: self.records)
    }
    
    private func applySnapshot(records: [Record]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Record>()
        snapshot.appendSections([.main])
        snapshot.reloadSections([.main])
        snapshot.appendItems(records)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
