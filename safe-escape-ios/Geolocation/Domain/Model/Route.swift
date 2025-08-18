//
//  Route.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

// 경로
struct Route {
    var totalDistance: Double // 총 거리
    var totalTime: Int // 총 소요 시간
    
    var points: [Coordinate] // 경로 포인트
    var paths: [[Coordinate]] // 경로
}
