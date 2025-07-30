//
//  ShelterRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/30/25.
//

import Foundation

class ShelterRepository {
    static let shared = ShelterRepository()
    
    private init() {}
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 내 주변 대피소 조회
    func getNearbyShelters(_ location: Coordinate) async throws -> [Shelter] {
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
        
        try await Task.sleep(for: .milliseconds(Int.random(in: 5...30) * 100))
        
        let range = Int.random(in: -3...15)
        guard range > 0 else {
            return []
        }
        
        return (0..<range).map { _ in
            var shelter = Shelter(id: String(UUID().uuidString.prefix(8)), name: String(UUID().uuidString.prefix(8)), address: String(UUID().uuidString.prefix(32)), coordinate: randomCoordinate(center: location, radiusInMeters: 1500), liked: Bool.random())
            
            shelter.distance = LocationUsecase.shared.getDirectDistance(from: location, to: shelter.coordinate)
            
            return shelter
        }
    }
}
