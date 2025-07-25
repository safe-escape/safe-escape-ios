//
//  ShelterInfoViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/25/25.
//

import Foundation

// 대피소 뷰모델
class ShelterInfoViewModel: ObservableObject {
    // 지도 뷰모델
    var mapViewModel: MapViewModel!
    
    // 대피소
    var shelter: Shelter! {
        didSet {
            // 대피소 데이터 새로 설정될 때마다, 관련 데이터 초기화
            route = nil
            liked = shelter?.liked ?? false
            loading = false
        }
    }
    
    // 찜 여부 (회원 전용)
    @Published var liked: Bool = false
    
    // 대피소 길찾기 경로
    var route: Route? = nil
    
    
    @Published var loading: Bool = false
    
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
    }
    
    // 길찾기
    func findRoute() {
        loading = true
        
        Task {
            let route = try? await FindUsecase.shared.findRoute(from: LocationUsecase.shared.getCurrentLocation(), to: shelter.coordinate)
            
            guard let route else {
                await MainActor.run {
                    loading = false
                }
                return
            }
            
            await MainActor.run {
                loading = false
                self.route = route
                mapViewModel.setRoute(route)
            }
        }
    }
    
    func toggleLiked() {
        // TODO: 회원 찜 기능 추가
        liked.toggle()
    }
    
}
