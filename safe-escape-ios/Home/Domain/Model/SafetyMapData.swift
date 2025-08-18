//
//  SafetyMapData.swift
//  safe-escape-ios
//
//  Created by Cindy on 7/23/25.
//

import Foundation

// 홈 지도 데이터
struct SafetyMapData {
    let shelters: [Shelter] // 대피소
    let crowded: [Crowded] // 혼잡도
    let crowdedAreas: [CrowdedArea] // 혼잡 지역
    let nearbyPopulation: CrowdedNearBy? // 근처 혼잡 지역
}
