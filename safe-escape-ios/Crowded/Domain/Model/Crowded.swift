//
//  Crowded.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

// 혼잡도 레벨
enum CrowdedLevel: String, CaseIterable {
    case free = "FREE" // 여유
    case normal = "NORMAL" // 보통
    case crowded = "CROWDED" // 조금 혼잡
    case veryCrowded = "VERY_CROWDED" // 매우 혼잡
}

// 혼잡도
struct Crowded {
    var coordinate: Coordinate // 좌표
    var level: CrowdedLevel // 혼잡도 레벨
}
