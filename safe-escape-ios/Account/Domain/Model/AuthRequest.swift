//
//  AuthRequest.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 로그인 요청 모델
struct LoginRequest {
    let email: String
    let password: String
}

// 회원가입 요청 모델
struct SignUpRequest {
    let name: String
    let email: String
    let password: String
}

// 로그인 응답 모델
struct LoginResponse {
    let user: User
    let tokens: TokenModel
}

// 회원가입 응답 모델
struct SignUpResponse {
    let user: User
    let message: String?
}