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
    
    // 홈 지도 데이터 조회
    func requestMapData() {
        // 데이터 초기화
        mapViewModel.clearMap()
        mapViewModel.showRefreshButton = false
        showExitInfo = false
        exitInfoViewModel.reset()
        showShelterInfo = false
        
        Task {
            // 검색할 위치 지정 - 지도 현재 위치 좌표 있으면 해당 위치로 / 그 외엔 사용자 현재 위치 기반
            let userLocation = try await LocationUsecase.shared.getCurrentLocation()
            var location: Coordinate! = mapViewModel.currentCenterPosition
            if location == nil {
                // 최초 로드이므로 사용자 위치 설정
                location = userLocation
                await MainActor.run {
                    self.mapViewModel.currentUserLocation = userLocation
                }
            }
            
            // 지도 위치 조회하는 위치로 변경
            await MainActor.run {
                self.mapViewModel.centerPosition = location
            }
            
            // 데이터 조회
            guard let mapData = try? await HomeUsecase.shared.requestData(location) else {
                return
            }
            
            // 혼잡 지역 내에 위치해 있는지 판단
            let isInsideCrowdedArea = mapData.crowdedAreas.contains(where: { crowdedArea in
                LocationUsecase.shared.isCoordinateInsidePolygon(point: userLocation, polygon: crowdedArea.coordinates)
            })
            
            // 데이터 셋팅
            await MainActor.run {
                // 지도 뷰모델에 마지막 검색한 위치 저장 및 데이터 셋팅
                self.mapViewModel.lastFindCenterPosition = location
                self.mapViewModel.setMapData(mapData)
                
                // 비상구 데이터 셋팅 및 노출 여부
                self.exitInfoViewModel.exits = mapData.exits
                if isInsideCrowdedArea {
                    self.mapViewModel.showUserLocation = true
                }
                self.showExitInfo = isInsideCrowdedArea
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
    }
}
