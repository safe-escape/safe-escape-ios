//
//  AuthError.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 인증 관련 에러
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case tokenExpired
    case tokenInvalid
    case refreshTokenExpired
    case networkError
    case serverError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .emailAlreadyExists:
            return "이미 사용 중인 이메일입니다."
        case .weakPassword:
            return "비밀번호가 너무 간단합니다."
        case .tokenExpired:
            return "토큰이 만료되었습니다. 다시 로그인해주세요."
        case .tokenInvalid:
            return "유효하지 않은 토큰입니다."
        case .refreshTokenExpired:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .serverError(let message):
            return message
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}