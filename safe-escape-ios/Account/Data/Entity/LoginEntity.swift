//
//  LoginEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 로그인 API 응답 Entity
struct LoginResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: LoginDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 로그인 데이터 Entity
struct LoginDataEntity: Entity {
    let accessToken: String
    let refreshToken: String
    let user: MemberDataEntity
    
    typealias Model = LoginResponse
    
    func map() -> LoginResponse {
        let tokens = TokenModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: 3600 // 기본값, 실제로는 서버에서 받아야 함
        )
        
        return LoginResponse(
            user: user.map(),
            tokens: tokens
        )
    }
}