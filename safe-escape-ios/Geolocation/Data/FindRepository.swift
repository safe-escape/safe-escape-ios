//
//  FindRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/22/25.
//

import Foundation

// 검색 관련 Repository
class FindRepository {
    
    static let shared = FindRepository()
    
    private init() {}

    // 주소 검색
    func findAddress(_ input: String, page: Int = 1) async throws -> (addresses: [Address], hasMoreData: Bool) {
        let entity = try await KakaoMapDataSource.shared.findAddress(input, page: page)
        
        // Entity to Model
        let addresses = entity.address.map { $0.map() }
        let hasMoreData = !entity.meta.isEnd
        
        return (addresses: addresses, hasMoreData: hasMoreData)
    }
    
    // 경로 검색
    func findRoute(_ start: Coordinate, _ end: Coordinate) async throws -> Route {
        let entity = try await TMapDataSource.shared.findRoute(start, end)
        
        // Entity to Model
        // 총 거리 / 소요 시간
        guard let totalTuple = entity.compactMap({ $0.properties.map() }).first else {
            throw ErrorDisplay(msg: "데이터 오류")
        }
        
        // 경로 포인트 / 경로
        var points: [Coordinate] = []
        var paths: [[Coordinate]] = []
        entity.forEach { entity in
            guard let geometry = entity.geometry.map(), geometry.count > 0 else {
                return
            }
            
            geometry.count == 1 ? points.append(contentsOf: geometry) : paths.append(geometry)
        }
        
        try await Task.sleep(for: .milliseconds(Int.random(in: 1...5) * 100))
        
        return Route(totalDistance: Double(totalTuple.totalDistance), totalTime: totalTuple.totalTime, points: points, paths: paths)
    }
}
