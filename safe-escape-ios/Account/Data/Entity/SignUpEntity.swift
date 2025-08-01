//
//  SignUpEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 회원가입 API 응답 Entity
struct SignUpResponseEntity: ResponseEntity {
    let success: Bool
    let data: SignUpDataEntity?
}

// 회원가입 데이터 Entity
struct SignUpDataEntity: Entity {
    let user: UserEntity
    let message: String?
    
    func map() -> SignUpResponse {
        return SignUpResponse(
            user: user.map(),
            message: message
        )
    }
}