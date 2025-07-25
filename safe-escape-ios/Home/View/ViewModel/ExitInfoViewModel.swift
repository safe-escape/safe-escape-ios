//
//  ExitInfoViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/25/25.
//

import Foundation


// 비상구 조회 상태
enum ExitInfoState {
    case idle // 비상구 추천 여부 미정
    case loading // 찾는 중
    case find // 비상구 찾음
}

class ExitInfoViewModel: ObservableObject {
    var mapViewModel: MapViewModel
    var exits: [Exit] = [] {
        didSet {
            state = .idle
            exit = nil
            route = nil
        }
    }
    @Published var state: ExitInfoState = .idle
    var exit: Exit? = nil
    var route: Route? = nil
    
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
    }
    
    // 찾은 비상구 있으면 보여주고, 없으면 길찾기 노출
    func load() {
        if let exit = exit, let route = route {
            mapViewModel.setRoute(route, exit)
        } else {
            state = .idle
        }
    }
    
    // 비상구 길찾기
    func findRoute() {
        Task {
            // 추천 비상구 찾기
            guard let exit = try? await findNearestExit() else {
                return
            }
            
            await MainActor.run {
                state = .loading
            }
            
            // 추천 비상구까지 길찾기 경로 조회
            let route = try? await FindUsecase.shared.findRoute(from: LocationUsecase.shared.getCurrentLocation(), to: exit.coordinate)
            
            guard let route else {
                return
            }
            
            await MainActor.run {
                self.exit = exit
                self.route = route
            
                // 상태 찾음으로 변경 및 지도에 루트 표시
                mapViewModel.setRoute(route, exit)
                state = .find
            }
        }
    }
    
    // 가장 가까운 비상구 찾기
    private func findNearestExit() async throws -> Exit? {
        // TODO: API로 가져오는 것으로 변경 필요
        let userLocation = try await LocationUsecase.shared.getCurrentLocation()
        
        var minDistance = LocationUsecase.shared.getDirectDistance(from: userLocation, to: exits.first!.coordinate)
        var nearestExit: Exit = exits.first!
        exits.forEach { exit in
            let distance = LocationUsecase.shared.getDirectDistance(from: userLocation, to: exit.coordinate)
            if distance < minDistance {
                minDistance = distance
                nearestExit = exit
            }
        }
        
        return nearestExit
    }
    
    // 데이터 초기화
    func reset() {
        exit = nil
        route = nil
    }
}

