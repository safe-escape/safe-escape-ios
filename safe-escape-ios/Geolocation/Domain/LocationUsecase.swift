//
//  LocationUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation
import CoreLocation

class LocationUsecase {
    static let shared = LocationUsecase()
    
    private init() {}
    
    // 사용자 현재 위치
    func getCurrentLocation() async throws -> Coordinate {
        // TODO: 사용자 위치 받아오는 것으로 변경 필요
        return Coordinate(latitude: 37.524771, longitude: 126.886062)
    }
    
    // 두 좌표간 직선 거리 계산
    func getDirectDistance(from start: Coordinate, to end: Coordinate) -> Double {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        
        return startLocation.distance(from: endLocation)
    }

    // 좌표가 폴리곤 안에 위치해있는지 판단 (Winding Number 알고리즘 사용)
    func isCoordinateInsidePolygon(point: Coordinate,polygon: [Coordinate]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var windingNumber = 0

        for i in 0..<polygon.count {
            let p1 = polygon[i]
            let p2 = polygon[(i + 1) % polygon.count]

            if p1.latitude <= point.latitude {
                if p2.latitude > point.latitude { // upward crossing
                    if isLeft(p1, p2, point) > 0 {
                        windingNumber += 1
                    }
                }
            } else {
                if p2.latitude <= point.latitude { // downward crossing
                    if isLeft(p1, p2, point) < 0 {
                        windingNumber -= 1
                    }
                }
            }
        }

        return windingNumber != 0
    }

    // Winding Number
    // 벡터 cross product: point가 p1→p2 벡터 왼쪽에 있으면 양수
    private func isLeft(
        _ p1: Coordinate,
        _ p2: Coordinate,
        _ point: Coordinate
    ) -> Double {
        return (p2.longitude - p1.longitude) * (point.latitude - p1.latitude)
             - (point.longitude - p1.longitude) * (p2.latitude - p1.latitude)
    }

}
