//
//  MapView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import SwiftUI
import NMapsMap

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        // 지도 카메라 delegate 설정
        mapView.addCameraDelegate(delegate: viewModel)
        
        // 첫 지도 center 위치 지정
        if let center = viewModel.centerPosition {
            mapView.latitude = center.latitude
            mapView.longitude = center.longitude
        }
        
        // 사용자 위치 오버레이 아이콘 지정
        mapView.locationOverlay.icon = NMFOverlayImage(name: "current_user_location_overlay")
        
        return mapView
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        // 사용자 위치 오버레이 show/hide 및 위치 지정
        if let currentUserLocation = viewModel.currentUserLocation {
            mapView.locationOverlay.hidden = false
            mapView.locationOverlay.location = NMGLatLng(lat: currentUserLocation.latitude, lng: currentUserLocation.longitude)
        }
        
        // 지도 센터 위치 이동 필요 시 이동
        if let cameraLocation = viewModel.centerPosition {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: cameraLocation.latitude, lng: cameraLocation.longitude))
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
            
            // 재이동 방지용 처리
            DispatchQueue.main.async {
                viewModel.centerPosition = nil
            }
        }
        
        // 길찾기 경로 있는 경우, 경로 노출
        if viewModel.route != nil {
            viewModel.paths.forEach { $0.mapView = mapView }
        }
        
        // 지도 UI 갱신 요청 시에만 UI 갱신
        guard viewModel.needUpdateMapOverlay else {
            return
        }
        
        // 마커 및 오버레이 표시
        viewModel.shelters.forEach { $0.mapView = mapView }
        viewModel.crowded.forEach { $0.mapView = mapView }
        viewModel.crowdedAreas.forEach { $0.mapView = mapView }
        viewModel.exits.forEach { $0.marker.mapView = mapView }
        
        // UI 재갱신 방지용 처리
        DispatchQueue.main.async {
            viewModel.needUpdateMapOverlay = false
        }
    }
    
}
