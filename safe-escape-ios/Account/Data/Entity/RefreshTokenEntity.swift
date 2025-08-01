//
//  RefreshTokenEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 토큰 갱신 API 응답 Entity
struct RefreshTokenResponseEntity: ResponseEntity {
    let success: Bool
    let data: RefreshTokenDataEntity?
}

// 토큰 갱신 데이터 Entity
struct RefreshTokenDataEntity: Entity {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int?
    
    func map() -> RefreshTokenResponse {
        return RefreshTokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
    }
}