//
//  Crowded.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

// 혼잡도 레벨
enum CrowdedLevel: CaseIterable {
    case free // 여유
    case normal // 보통
    case crowded // 조금 혼잡
    case veryCrowded // 매우 혼잡
}

// 혼잡도
struct Crowded {
    var coordinate: Coordinate // 좌표
    var level: CrowdedLevel // 혼잡도 레벨
}
