//
//  RecordDetailViewController.swift
//  Muyeon
//
//  Created by 김민성 on 10/7/25.
//

import UIKit

import SnapKit

class RecordDetailViewController: UIViewController {

    // MARK: - Properties
    private let recordDetailView = RecordDetailView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Diary>!
    
    // 예시 데이터
    private var performance: Performance!
    private var diaries: [Diary] = []

    // CollectionView의 Section을 정의
    enum Section {
        case main
    }

    // MARK: - Lifecycle
    override func loadView() {
        self.view = recordDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSampleData()
        configureUI()
        configureDataSource()
        applySnapshot()
    }
    
    // MARK: - Setup
    private func configureUI() {
        self.view.backgroundColor = .systemGroupedBackground
        self.title = "공연 기록"
        recordDetailView.configureHeader(with: performance)
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

        diaries = [
            Diary(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-06-20")!,
                rating: 4.5,
                reviewText: "",
                diaryImageUUIDs: ["0"]
            ),
            Diary(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-10-01")!,
                rating: 5.0,
                reviewText: "평생 잊지 못할 경험! 아미들과 함께 떼창하는 순간이 최고였다. 무대 연출도 정말 화려했다.",
                diaryImageUUIDs: []
            ),
            Diary(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-03-15")!,
                rating: 5.0,
                reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.",
                diaryImageUUIDs: ["0", "1", "2", "3", "4"]
            ),
            Diary(
                id: UUID().uuidString,
                performanceID: p1.id,
                createdAt: Date(),
                viewedAt: dateFormatter.date(from: "2024-03-15")!,
                rating: 5.0,
                reviewText: "정말 감동적이었다. 장발장 역의 연기가 특히 인상적이었고, 마지막 장면에서 눈물이 났다.",
                diaryImageUUIDs: ["0", "1", "2", "3", "4"]
            )
        ]
    }
}

// MARK: - UICollectionView Compositional Layout & Diffable DataSource
extension RecordDetailViewController {
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<RecordCell, Diary> { cell, indexPath, diary in
            cell.configure(with: diary)
            
            // 사진 셀 탭 핸들러 설정
            cell.onPhotoTapped = { [weak self] image in
                guard let self else { return }
                
                let photoVC = PhotoViewController(image: image)
                photoVC.modalPresentationStyle = .overFullScreen
                photoVC.modalTransitionStyle = .crossDissolve
                self.present(photoVC, animated: true)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Diary>(collectionView: recordDetailView.collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Diary) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // 헤더 설정
        let headerRegistration = UICollectionView.SupplementaryRegistration<RecordSectionHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) {
            (headerView, string, indexPath) in
            headerView.configure(count: self.diaries.count)
        }

        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.recordDetailView.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: index)
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Diary>()
        snapshot.appendSections([.main])
        snapshot.appendItems(diaries)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
