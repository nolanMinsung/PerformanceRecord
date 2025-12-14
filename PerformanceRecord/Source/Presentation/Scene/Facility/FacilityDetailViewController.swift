//
//  FacilityDetailViewController.swift
//  Muyeon
//
//  Created by 김민성 on 9/30/25.
//

import UIKit
import SafariServices

class FacilityDetailViewController: UIViewController {

    private let rootView = FacilityDetailView()
    private let container: DIContainer
    private let viewModel: FacilityDetailViewModel
    
    init(facilityID: String, container: DIContainer) {
        self.container = container
        self.viewModel = FacilityDetailViewModel(
            facilityID: facilityID,
            fetchFacilityDetailUseCase: container.resolve(type: FetchFacilityDetailUseCase.self)
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        // 뷰 컨트롤러의 기본 뷰를 커스텀 뷰로 설정
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "공연장 정보"
        
        // 네비게이션 바 스타일 설정
        navigationController?.navigationBar.prefersLargeTitles = false
        
        rootView.linkButton.addTarget(self, action: #selector(onLinkButtonTapped), for: .touchUpInside)
        
        Task {
            let facility = try await viewModel.fetchFacilityDetailUseCase.execute(facilityID: viewModel.facilityID)
            rootView.configure(with: facility)
        }
    }
    
    @objc private func onLinkButtonTapped() {
        guard let relatedURL = rootView.relatedURL else { return }
        let safariViewController = SFSafariViewController(url: relatedURL)
        safariViewController.modalPresentationStyle = .formSheet
        present(safariViewController, animated: true)
    }
    
    func createDummyFacility() -> Facility {
        let concertHall = SubVenue(
            name: "콘서트홀",
            id: "sub1",
            seatScale: 2600,
            hasOrchestraPit: true,
            hasPracticeRoom: true,
            hasDressingRoom: true,
            hasOutdoorStage: false,
            disabledSeatScale: 24,
            stageArea: "18m x 12m"
        )
        
        let cjTowallTheater = SubVenue(
            name: "CJ 토월극장",
            id: "FC000001-01",
            seatScale: 1004,
            hasOrchestraPit: true,
            hasPracticeRoom: false,
            hasDressingRoom: true,
            hasOutdoorStage: false,
            disabledSeatScale: 10,
            stageArea: nil
        )
        
        
        let childrenLounge = SubVenue(
            name: "1101어린이라운지",
            id: "FC000001-14",
            seatScale: 0,
            hasOrchestraPit: false,
            hasPracticeRoom: false,
            hasDressingRoom: false,
            hasOutdoorStage: false,
            disabledSeatScale: nil,
            stageArea: nil
        )
        
        let olympicHall = SubVenue(
            name: "올림픽홀",
            id: "FC001247-03",
            seatScale: 2452,
            hasOrchestraPit: false,
            hasPracticeRoom: true,
            hasDressingRoom: true,
            hasOutdoorStage: false,
            disabledSeatScale: 22,
            stageArea: "23.1X18.5X8.5"
        )
        
        let subyun = SubVenue(
            name: "야외(수변무대)",
            id: "FC001247-08",
            seatScale: 1000,
            hasOrchestraPit: false,
            hasPracticeRoom: true,
            hasDressingRoom: true,
            hasOutdoorStage: true,
            disabledSeatScale: nil,
            stageArea: nil
        )
        
        let sampleDetail = FacilityDetail(
            totalSeatScale: 2600,
            telNumber: "02-580-1300",
            relatedURL: "https://www.sac.or.kr",
            address: "서울특별시 서초구 남부순환로 2406",
            latitude: 37.4786,
            longitude: 127.0114,
            hasRestaurant: true,
            hasCafe: true,
            hasStore: true,
            hasNolibang: true,
            hasSuyusil: false,
            hasParkingBarrier: true,
            hasRestroomBarrier: true,
            hasRunwayBarrier: true,
            hasElevatorBarrier: true,
            hasParkingLot: false,
            subVenues: [
                concertHall,
                cjTowallTheater,
                childrenLounge,
                olympicHall,
                subyun
            ]
        )
        
        let sampleFacility = Facility(
            id: "FC000001",
            name: "예술의전당",
            performanceCount: 3,
            character: .cultureArtCenter,
            sidoName: .seoul,
            gugunName: nil,
            openYear: 1988,
            detail: sampleDetail
        )
        
        return sampleFacility
    }
}
