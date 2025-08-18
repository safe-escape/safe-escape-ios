//
//  HomeViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI
import Combine

// 홈 뷰모델
class HomeViewModel: ObservableObject {
    // 주소 검색 뷰모델
    var inputAddressViewModel: InputAddressViewModel = InputAddressViewModel()
    // 지도 뷰모델
    var mapViewModel: MapViewModel = MapViewModel()
    // 대피소 오버레이 뷰모델
    var shelterInfoViewModel: ShelterInfoViewModel!
    // 혼잡지역 - 비상구 오버레이 뷰모델
    var exitInfoViewModel: ExitInfoViewModel!
    
    @Published var loading: Bool = false
    
    // 대피소 및 비상구 오버레이 노출 여부
    @Published var showExitInfo: Bool = false
    @Published var showShelterInfo: Bool = false {
        didSet {
            // 대피소 오버레이 닫은 경우, 대피소 마커 reset
            if !showShelterInfo, mapViewModel.selectedShelter != nil {
                mapViewModel.resetShelterMarker()
            }
        }
    }
    
    // Refresh 버튼 노출 여부
    @Published var showRefreshButton: Bool = false
    
    // 주위 지역 정보
    @Published var info: String? = nil
    
    // 홈 지도 데이터 조회
    func requestMapData(_ shelter: Shelter? = nil) {
        // 데이터 초기화
        mapViewModel.clearMap()
        mapViewModel.showRefreshButton = false
        info = nil
        showExitInfo = false
        exitInfoViewModel.reset()
        showShelterInfo = false
        
        loading = true
        
        Task {
            defer {
                DispatchQueue.main.async {
                    self.loading = false
                }
            }
            
            if let shelter = shelter {
                // 지도 위치 조회하는 위치로 변경
                await MainActor.run {
                    self.mapViewModel.centerPosition = shelter.coordinate
                    self.mapViewModel.lastFindCenterPosition = shelter.coordinate
                }
                try await Task.sleep(for: .milliseconds(700))
            }
            
            // 검색할 위치 지정 - 지도 현재 위치 좌표 있으면 해당 위치로 / 그 외엔 사용자 현재 위치 기반
            let userLocation = try await LocationUsecase.shared.getCurrentLocation()
            var location: Coordinate! = mapViewModel.currentCenterPosition
            if location == nil || mapViewModel.lastFindCenterPosition == nil {
                // 최초 로드이므로 사용자 위치 설정
                location = userLocation
                await MainActor.run {
                    self.mapViewModel.currentUserLocation = userLocation
                }
                try await Task.sleep(for: .milliseconds(500))
            }
            
            // 지도 위치 조회하는 위치로 변경
            await MainActor.run {
                self.mapViewModel.centerPosition = location
                self.mapViewModel.lastFindCenterPosition = location
            }
            
            var bounds: MapBounds!
            var count = 0
            repeat {
                try await Task.sleep(for: .milliseconds(100))
                bounds = self.mapViewModel.currentBounds
                count += 1
            } while count < 5 && bounds == nil
            
            if bounds == nil {
                // TODO: 에러 처리
                return
            }
            
            // 데이터 조회
            guard let mapData = try? await HomeUsecase.shared.requestData(bounds) else {
                return
            }
            
            // 혼잡 지역 내에 위치해 있는지 판단
            var userCrowdedAreaExits: [Exit] = []
            var userIsInsideCrowdedArea = false
            mapData.crowdedAreas.forEach { crowdedArea in
                let isInsideCrowedeArea = LocationUsecase.shared.isCoordinateInsidePolygon(point: userLocation, polygon: crowdedArea.coordinates)
                if isInsideCrowedeArea {
                    userIsInsideCrowdedArea = true
                    userCrowdedAreaExits.append(contentsOf: crowdedArea.exits)
                }
            }
            
            // 데이터 셋팅
            await MainActor.run {
                loading = false
                self.mapViewModel.currentUserLocation = userLocation
                
                self.shelterInfoViewModel.setShelterList(mapData.shelters)
                
                // 지도 뷰모델에 데이터 셋팅
                self.mapViewModel.setMapData(mapData, shelter)
                
                // 비상구 데이터 셋팅 및 노출 여부
                self.exitInfoViewModel.exits = userCrowdedAreaExits
                self.showExitInfo = userIsInsideCrowdedArea
                
                // 주위 지역 정보 셋팅
                if let nearbyPopulation = mapData.nearbyPopulation {
                    var crowdedImoji = ""
                    var crowdedLevelText = ""
                    switch nearbyPopulation.crowded.level {
                    case .free:
                        crowdedImoji = "🌿"
                        crowdedLevelText = "가장 여유로워요"
                    case .normal:
                        crowdedImoji = "😶"
                        crowdedLevelText = "보통이에요"
                    case .crowded, .veryCrowded:
                        crowdedImoji = "🔥"
                        crowdedLevelText = "가장 혼잡해요"
                    }
                    
                    self.info = "\(crowdedImoji) 근처에서 \(nearbyPopulation.address)\(SubjectFormatter.getSubjectMarker(nearbyPopulation.address)) \(crowdedLevelText)"
                }
            }
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    init() {
        shelterInfoViewModel = ShelterInfoViewModel(mapViewModel: mapViewModel)
        exitInfoViewModel = ExitInfoViewModel(mapViewModel: mapViewModel)
        
        // 주소 검색 뷰모델 -> 주소 검색 후 선택 시, 지도 해당 주소 좌표로 이동
        inputAddressViewModel.$selectedAddress
            .sink { [weak self] address in
                guard let address = address, let self = self else {
                    return
                }
                
                self.mapViewModel.centerPosition = address.coordinate
                self.inputAddressViewModel.selectedAddress = nil
            }
            .store(in: &cancellables)
        
        // 지도 뷰모델 -> 선택한 대피소 유무에 따라 대피소 오버레이 노출 여부 설정
        mapViewModel.$selectedShelter
            .sink { [weak self] shelter in
                if let shelter = shelter {
                    self?.shelterInfoViewModel.shelter = shelter
                }
                self?.showShelterInfo = shelter != nil
            }
            .store(in: &cancellables)
        
        // 지도 뷰모델 -> Refresh 버튼 노출 여부에 따라 Refresh 버튼 노출 여부 설정
        mapViewModel.$showRefreshButton
            .sink { [weak self] show in
                self?.showRefreshButton = show
            }
            .store(in: &cancellables)
        
        // 지도 뷰모델 -> 대피소 노출 on/off 설정
        mapViewModel.$showShelters
            .sink { [weak self] show in
                guard !show else {
                    self?.showShelterInfo = false
                    return
                }
                
                self?.showShelterInfo = false
            }
            .store(in: &cancellables)
    }
    
}
