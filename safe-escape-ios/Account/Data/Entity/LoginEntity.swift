//
//  LoginEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 로그인 API 응답 Entity
struct LoginResponseEntity: ResponseEntity {
    let success: Bool
    let data: LoginDataEntity?
}

// 로그인 데이터 Entity
struct LoginDataEntity: Entity {
    let user: UserEntity
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int?
    let tokenType: String?
    
    func map() -> LoginResponse {
        let tokens = TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            tokenType: tokenType ?? "Bearer"
        )
        
        return LoginResponse(
            user: user.map(),
            tokens: tokens
        )
    }
}