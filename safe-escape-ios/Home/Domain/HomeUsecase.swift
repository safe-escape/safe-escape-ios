//
//  HomeUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation

class HomeUsecase {
    static let shared = HomeUsecase()
    
    private init() {}
    
    // 홈 데이터 조회
    func requestData(_ location: Coordinate) async throws -> SafetyMapData {
        try await HomeRepository.shared.requestData(location)
    }
}
