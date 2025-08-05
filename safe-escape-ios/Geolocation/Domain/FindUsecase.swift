//
//  FindUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/22/25.
//

import Foundation

// 검색 관련 Usecase
class FindUsecase {
    
    static let shared = FindUsecase()
    
    private init() {}
    
    // 주소 검색
    func findAddress(_ input: String, page: Int = 1) async throws -> (addresses: [Address], hasMoreData: Bool) {
        try await FindRepository.shared.findAddress(input, page: page)
    }
    
    // 경로 검색
    func findRoute(from start: Coordinate, to end: Coordinate) async throws -> Route {
        try await FindRepository.shared.findRoute(start, end)
    }
    
}
