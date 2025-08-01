//
//  TokenModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// JWT 토큰 모델
struct TokenModel {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int? // 만료 시간 (초)
    let tokenType: String // "Bearer"
    
    init(accessToken: String, refreshToken: String, expiresIn: Int? = nil, tokenType: String = "Bearer") {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}

// 토큰 갱신 요청
struct RefreshTokenRequest {
    let refreshToken: String
}

// 토큰 갱신 응답
struct RefreshTokenResponse {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int?
}