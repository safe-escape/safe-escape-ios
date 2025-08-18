//
//  CrowdedArea.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

// 혼잡 지역
struct CrowdedArea {
    let id: Int
    let coordinates: [Coordinate] // 좌표(폴리곤)
    let exits: [Exit] // 비상구 목록
}

// 비상구
struct Exit {
    let id: Int
    var coordinate: Coordinate // 좌표
}
