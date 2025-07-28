//
//  CrowdedUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import Foundation

// 혼잡도 Usecase
class CrowdedUsecase {
    static let shared = CrowdedUsecase()
    
    private init() {}
    
    // 내 주변 혼잡한 지역 리스트 조회
    func getCrowdedNearByList() async throws -> [CrowdedNearBy] {
        // 현재 사용자 위치 받아오기
        let location = try await LocationUsecase.shared.getCurrentLocation()
        return try await CrowdedRepository.shared.getCrowdedNearByList(location)
    }
    
    // 혼잡도 예상
    func expectCrowded(_ location: Coordinate, _ date: Date) async throws -> CrowdedLevel {
        return try await CrowdedRepository.shared.expectCrowded(location, date)
    }
    
}
