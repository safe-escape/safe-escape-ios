//
//  MapViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation
import NMapsMap

// 지도 뷰모델
class MapViewModel: NSObject, ObservableObject {
    // 지도 위치 이동 시 좌표
    @Published var centerPosition: Coordinate?
    // 현재 지도 위치(카메라 좌표)
    var currentCenterPosition: Coordinate?
    // 마지막으로 검색한 지도 위치
    var lastFindCenterPosition: Coordinate?
    
    // Refresh 버튼 노출 여부
    @Published var showRefreshButton: Bool = false
    
    // 사용자 현재 위치 좌표 및 노출 여부
    @Published var showUserLocation: Bool = false
    @Published var currentUserLocation: Coordinate? = nil
    
    // 대피소
    var shelters: [NMFMarker] = []
    @Published var selectedShelter: Shelter?
    
    // 혼잡도 / 혼잡 지역 / 비상구
    var crowded: [NMFCircleOverlay] = []
    var crowdedAreas: [NMFPolygonOverlay] = []
    var exits: [(data: Exit, marker: NMFMarker)] = []
    var selectedExit: Exit?
    
    // 지도 UI(마커 및 오버레이) 갱신 필요 여부
    @Published var needUpdateMapOverlay: Bool = false
    
    // 길찾기 경로
    @Published var route: Route?
    var points: [NMFCircleOverlay] = []
    var paths: [NMFPath] = []
    
    // 대피소 / 비상구 마커 이미지
    private let shelterMarkerImage = NMFOverlayImage(name: "shelter_marker")
    private let shelterMarkerSelectedImage = NMFOverlayImage(name: "shelter_marker_selected")
    
    private let exitMarkerImage = NMFOverlayImage(name: "exit_marker")
    private let exitMarkerSelectedImage = NMFOverlayImage(name: "exit_marker_selected")
    
    // 마커 선택 여부에 따른 z-index 설정용
    private let selectedMarkerZIndex = 250000
    private let defaultMarkerZIndex = 200000
    
    // 지도 UI(마커 및 오버레이) 생성
    func setMapData(_ data: SafetyMapData) {
        // 대피소 마커
        shelters = data.shelters.map { shelter in
            let marker = NMFMarker(position: NMGLatLng(lat: shelter.coordinate.latitude, lng: shelter.coordinate.longitude), iconImage: shelterMarkerImage)
            marker.width = 48
            marker.height = 48
            
            // 대피소 마커 toggle 처리
            marker.touchHandler = { overlay in
                if let marker = overlay as? NMFMarker {
                    if marker.iconImage == self.shelterMarkerImage {
                        // 대피소 마커 선택 시, 선택된 마커로 변경
                        self.resetShelterMarker()
                        marker.iconImage = self.shelterMarkerSelectedImage
                        marker.globalZIndex = self.selectedMarkerZIndex
                        self.selectedShelter = shelter
                    } else {
                        // 이미 선택된 마커 선택 시, 선택된 마커 해제 및 대피소 길찾기 경로 지우기
                        marker.iconImage = self.shelterMarkerImage
                        marker.globalZIndex = self.defaultMarkerZIndex
                        self.selectedShelter = nil
                        self.clearShelterRoute()
                    }
                }
                return true
            }
            
            return marker
        }
        
        // 혼잡도(원 오버레이)
        crowded = data.crowded.map { crowded in
            let overlay = NMFCircleOverlay()
            overlay.center = NMGLatLng(lat: crowded.coordinate.latitude, lng: crowded.coordinate.longitude)
            overlay.radius = 500 // 반경 500m
            
            // 혼잡도에 따른 색상 설정
            switch crowded.level {
            case .veryCrowded:
                overlay.fillColor = .veryCrowded
            case .crowded:
                overlay.fillColor = .crowded
            case .normal:
                overlay.fillColor = .normal
            case .free:
                overlay.fillColor = .free
            }
            overlay.fillColor = overlay.fillColor.withAlphaComponent(0.5)
            
            return overlay
        }
        
        // 혼잡 지역(폴리곤 오버레이)
        crowdedAreas = data.crowdedAreas.compactMap { crowdedArea in
            let coordinates = crowdedArea.coordinates.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
            let overlay = NMFPolygonOverlay(coordinates)
            overlay?.fillColor = .accent.withAlphaComponent(0.2)
            return overlay
        }
        
        // 비상구 마커
        exits = data.exits.map { exit in
            let marker = NMFMarker(position: NMGLatLng(lat: exit.coordinate.latitude, lng: exit.coordinate.longitude), iconImage: exitMarkerImage)
            marker.width = 48
            marker.height = 48
            
            // 선택된 비상구 처리를 위해 tuple로 저장
            return (exit, marker)
        }
        
        // 지도 UI 갱신 요청
        needUpdateMapOverlay = true
    }
    
    // 지도 UI 제거
    func clearMap() {
        route = nil
        selectedShelter = nil
        selectedExit = nil
        
        shelters.forEach { $0.mapView = nil }
        crowded.forEach { $0.mapView = nil }
        crowdedAreas.forEach { $0.mapView = nil }
        exits.forEach { $0.marker.mapView = nil }
        
        clearRoute()
    }
    
    // 대피소 마커 상태 reset
    func resetShelterMarker() {
        shelters.forEach { $0.iconImage = shelterMarkerImage }
        
        // 대피소 길찾기 경로 제거
        clearShelterRoute()
    }
    
    // 비상구 마커 상태 reset
    func resetExitMarker() {
        exits.forEach { $0.marker.iconImage = exitMarkerImage }
    }
    
    // 길찾기 경로 제거
    func clearRoute() {
        route = nil
        paths.forEach { $0.mapView = nil }
    }
    
    // 대피소 길찾기 경로 제거
    func clearShelterRoute() {
        // 선택된 비상구 존재 시, 비상구 경로이므로 제거하지 않음
        guard selectedExit == nil else { return }
        clearRoute()
    }
    
    // 길찾기 경로(Path) 생성
    func setRoute(_ route: Route, _ exit: Exit? = nil) {
        // 기존 길찾기 경로 제거
        clearRoute()
        
        // 비상구 경로인 경우, 선택된 비상구 마커 처리
        if let exit = exit {
            selectedExit = exit
            exits.forEach {
                if $0.data.coordinate == exit.coordinate {
                    $0.marker.iconImage = exitMarkerSelectedImage
                    $0.marker.globalZIndex = selectedMarkerZIndex
                } else {
                    $0.marker.iconImage = exitMarkerImage
                    $0.marker.globalZIndex = defaultMarkerZIndex
                }
            }
        } else {
            // 대피소 경로인 경우, 비상구 마커 상태 reset
            selectedExit = nil
            resetExitMarker()
        }
        
        // 경로 생성
        paths = route.paths.map { path in
            let pathOverlay = NMFPath()
            pathOverlay.path = NMGLineString(points: path.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) })
            pathOverlay.outlineWidth = 0
            // 경로 타입(대피소 경로 / 비상구 경로)에 따라 색상 변경
            pathOverlay.color = (exit == nil ? UIColor.pointRed : UIColor.accent).withAlphaComponent(0.5)
            
            return pathOverlay
        }
        
        // 길찾기이므로 현재 사용자 위치 force 노출 및 지도 갱신 요청
        self.showUserLocation = true
        self.route = route
    }
}

// 네이버 지도 카메라 Delegate
extension MapViewModel: NMFMapViewCameraDelegate {
    
    // 카메라 이동 끝난 경우
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        // 마지막으로 검색한 위치에서 현재 지도 위치(카메라 좌표)가 1km 이상 차이나는 경우, refresh 버튼 노출
        let currentCenterPossition = Coordinate(latitude: mapView.cameraPosition.target.lat, longitude: mapView.cameraPosition.target.lng)
        self.currentCenterPosition = currentCenterPossition
        
        guard let lastCenterPosition = self.lastFindCenterPosition else {
            return
        }
        
        let needShowUserLocation = LocationUsecase.shared.getDirectDistance(from: lastCenterPosition, to: currentCenterPossition) > 1000
        if needShowUserLocation != showRefreshButton {
            showRefreshButton = needShowUserLocation
        }
    }
    
}
