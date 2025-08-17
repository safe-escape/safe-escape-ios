//
//  RefreshTokenEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 토큰 갱신 요청 모델
struct RefreshTokenRequestEntity: Codable {
    let refreshToken: String
}

// 토큰 갱신 API 응답 Entity
struct RefreshTokenResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: RefreshTokenDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 토큰 갱신 데이터 Entity
struct RefreshTokenDataEntity: Entity {
    let accessToken: String
    let refreshToken: String
    
    typealias Model = RefreshTokenResponse
    
    func map() -> RefreshTokenResponse {
        return RefreshTokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: 3600 // 기본값, 실제로는 서버에서 받아야 함
        )
    }
}
