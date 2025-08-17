//
//  HomeUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation

class HomeUsecase {
    static let shared = HomeUsecase()
    
    private init() {}
    
    // 홈 데이터 조회
    func requestData(_ bounds: MapBounds) async throws -> SafetyMapData {
        let currentUserLoation = try await LocationUsecase.shared.getCurrentLocation()
        let data = try await HomeRepository.shared.requestData(bounds: bounds)
        
        // CrowdedArea의 coordinates를 시계방향으로 정렬
        let sortedCrowdedAreas = data.crowdedAreas.map { area in
            var sortedArea = area
            sortedArea = CrowdedArea(
                id: area.id,
                coordinates: sortCoordinatesClockwise(area.coordinates),
                exits: area.exits
            )
            return sortedArea
        }
        
        return SafetyMapData(shelters: data.shelters.map {
                                        var shelter = $0
                                        shelter.distance = LocationUsecase.shared.getDirectDistance(from: currentUserLoation,
                                                                                                    to: $0.coordinate)
                                        return shelter
                                    },
                             crowded: data.crowded,
                             crowdedAreas: sortedCrowdedAreas,
                             nearbyPopulation: data.nearbyPopulation)
    }
    
    // 좌표를 시계방향으로 정렬하는 함수
    private func sortCoordinatesClockwise(_ coordinates: [Coordinate]) -> [Coordinate] {
        guard coordinates.count >= 3 else { return coordinates }
        
        // 중심점 계산 (centroid)
        let centerLat = coordinates.map(\.latitude).reduce(0, +) / Double(coordinates.count)
        let centerLng = coordinates.map(\.longitude).reduce(0, +) / Double(coordinates.count)
        let center = Coordinate(latitude: centerLat, longitude: centerLng)
        
        // 각 좌표의 중심점으로부터의 각도 계산하여 정렬
        let sortedCoordinates = coordinates.sorted { coord1, coord2 in
            let angle1 = atan2(coord1.latitude - center.latitude, coord1.longitude - center.longitude)
            let angle2 = atan2(coord2.latitude - center.latitude, coord2.longitude - center.longitude)
            return angle1 > angle2 // 시계방향 정렬 (각도가 큰 것부터)
        }
        
        return sortedCoordinates
    }
    
    // 비상구 랭킹 조회 - 가장 좋은 비상구 반환
    func getBestExit(_ exits: [Exit]) async throws -> Exit? {
        return try await HomeRepository.shared.getBestExit(exits)
    }
}
