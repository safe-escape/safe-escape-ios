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
    func findAddress(_ input: String) async throws -> [Address] {
        try await FindRepository.shared.findAddress(input)
    }
    
}
