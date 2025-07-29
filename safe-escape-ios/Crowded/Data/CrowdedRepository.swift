//
//  CrowdedRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import Foundation

// 혼잡도 Repository
class CrowdedRepository {
    static let shared = CrowdedRepository()
    
    private init() {}
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 내 주변 혼잡한 지역 리스트 조회
    func getCrowdedNearByList(_ location: Coordinate) async throws -> [CrowdedNearBy] {
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
        
        try await Task.sleep(for: .seconds(Int.random(in: 0...2)))
        
        return (0...Int.random(in: 3...10)).map { _ in
            CrowdedNearBy(crowded: Crowded(coordinate: randomCoordinate(center: location, radiusInMeters: 500), level: CrowdedLevel.allCases.randomElement() ?? .free), address: String(UUID().uuidString.prefix(8)))
        }
    }
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 혼잡도 예상 조회
    func expectCrowded(_ location: Coordinate, _ date: Date) async throws -> CrowdedLevel {
        try await Task.sleep(for: .seconds(Int.random(in: 0...2)))
        
        return .allCases.randomElement() ?? .free
    }
}
