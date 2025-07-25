//
//  HomeRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation

class HomeRepository {
    static let shared = HomeRepository()
    
    private init() {}
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 메인 데이터 조회
    func requestData(_ location: Coordinate) async throws -> SafetyMapData {
        // 해당 좌표로 부터 반경(m) 안의 랜덤 좌표 생성
        func randomCoordinate(
            center: Coordinate,
            radiusInMeters: Double
        ) -> Coordinate {
            // 무작위 각도 (0 ~ 2π)
            let theta = Double.random(in: 0..<2 * .pi)
            
            // 무작위 거리 (0 ~ radius), √로 보정해서 균일 분포 유지
            let distance = sqrt(Double.random(in: 0...1)) * radiusInMeters

            // 위도 변화 (1도 ≈ 111,000m)
            let deltaLat = distance * cos(theta) / 111_000.0

            // 경도 변화 (위도에 따른 보정 필요)
            let deltaLng = distance * sin(theta) / (111_000.0 * cos(center.latitude * .pi / 180))

            return Coordinate(
                latitude: center.latitude + deltaLat,
                longitude: center.longitude + deltaLng
            )
        }
        
        let shelters = (0..<10).map { _ in
            var shelter = Shelter(id: String(UUID().uuidString.prefix(8)), name: String(UUID().uuidString.prefix(8)), address: String(UUID().uuidString.prefix(32)), coordinate: randomCoordinate(center: location, radiusInMeters: 1500), liked: Bool.random())
            
            shelter.distance = LocationUsecase.shared.getDirectDistance(from: location, to: shelter.coordinate)
            
            return shelter
        }
        
        let crowded = (0..<3).map { _ in
            Crowded(coordinate: randomCoordinate(center: location, radiusInMeters: 2000), level: CrowdedLevel.allCases.randomElement() ?? .free)
        }
        
        // 좌표 기반 랜덤 폴리곤 생성
        func generatePolygonPoints(center: Coordinate, count: Int = 8, radius: Double = 0.005) -> [Coordinate] {
            // 1. 랜덤한 각도 배열 생성
            let angles = (0..<count).map { _ in Double.random(in: 0..<2 * .pi) }.sorted()

            // 2. 각도에 따라 점 생성 (원 형태로 퍼뜨리기)
            let points = angles.map { angle -> Coordinate in
                let r = radius * Double.random(in: 0.7...1.0) // 반지름 약간 랜덤하게
                let dx = r * cos(angle)
                let dy = r * sin(angle)

                return Coordinate(
                    latitude: center.latitude + dy,
                    longitude: center.longitude + dx
                )
            }

            return points
        }
        
        var exits: [Exit] = []
        let crowdedAreas = (0..<3).map { _ in
            let center = randomCoordinate(center: location, radiusInMeters: 1500)
            let crowdedArea = CrowdedArea(coordinates: generatePolygonPoints(center: center, count: Int.random(in: 5...8)))
            
            crowdedArea.coordinates.forEach {
                exits.append(Exit(coordinate: $0))
            }
            
            return crowdedArea
        }
        
        return SafetyMapData(shelters: shelters, crowded: crowded, crowdedAreas: crowdedAreas, exits: exits)
    }
}
