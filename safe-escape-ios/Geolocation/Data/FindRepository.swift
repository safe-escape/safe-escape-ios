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
    func findAddress(_ input: String) async throws -> [Address] {
        let entity = try await NaverMapDataSource.shared.findAddress(input)
        
        // Entity to Model
        return entity.address.map { $0.map() }
    }
    
}
