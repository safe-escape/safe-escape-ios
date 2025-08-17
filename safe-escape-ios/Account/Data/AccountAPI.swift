//
//  AuthAPI.swift
//  safe-escape-ios
//
//  Created by Cindy on 8/14/25.
//

import Foundation
import Moya

enum AuthAPI {
    case register(request: SignUpRequest) // 회원가입
    case login(request: LoginRequest) // 로그인
    case logout // 로그아웃
    case refresh(request: RefreshTokenRequestEntity) // 토큰 갱신
    case getMe // 회원 정보 조회
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://terrapin-fresh-haddock.ngrok-free.app")!
    }
    
    var path: String {
        switch self {
        case .register:
            return "/api/auth/register"
        case .login:
            return "/api/auth/login"
        case .logout:
            return "/api/auth/logout"
        case .refresh:
            return "/api/auth/refresh"
        case .getMe:
            return "/api/members/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register, .login, .logout, .refresh:
            return .post
        case .getMe:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .register(let request):
            return .requestJSONEncodable(request)
        case .login(let request):
            return .requestJSONEncodable(request)
        case .refresh(let request):
            return .requestJSONEncodable(request)
        case .logout, .getMe:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        var headers = ["Content-Type": "application/json"]
        
        // 로그인되어 있으면 Access Token 추가
        if let accessToken = TokenStorage.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
    
    
}
