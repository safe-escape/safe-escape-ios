//
//  SignUpEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 회원가입 API 응답 Entity
struct SignUpResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: SignUpDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 회원가입 데이터 Entity
struct SignUpDataEntity: Entity {
    let accessToken: String
    let refreshToken: String
    
    typealias Model = SignUpResponse
    
    func map() -> SignUpResponse {
        return SignUpResponse(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}
