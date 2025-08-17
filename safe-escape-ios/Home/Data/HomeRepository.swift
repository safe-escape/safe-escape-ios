//
//  HomeRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation

class HomeRepository {
    static let shared = HomeRepository()
    
    private init() {}
    
    // 메인 데이터 조회
    func requestData(bounds: MapBounds) async throws -> SafetyMapData {
        try await HomeDataSource.shared.getData(bounds: bounds).map()
    }
    
    // 비상구 랭킹 조회 - 가장 좋은 비상구 1개 반환
    func getBestExit(_ exits: [Exit]) async throws -> Exit? {
        return try await HomeDataSource.shared.rankExits(exits).map().first
    }
}
