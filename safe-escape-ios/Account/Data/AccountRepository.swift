//
//  AccountRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

class AccountRepository {
    static let shared = AccountRepository()
    
    private init() {}
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 로그인
    func login(_ request: LoginRequest) async throws -> LoginResponse {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(for: .seconds(Int.random(in: 1...3)))
        
        // 랜덤 성공/실패 (80% 성공률)
        let shouldSucceed = Bool.random() ? true : (Bool.random() ? true : (Bool.random() ? true : false))
        
        if !shouldSucceed {
            // 랜덤 실패 케이스
            let errors: [AuthError] = [.invalidCredentials, .networkError, .serverError("서버 오류")]
            throw errors.randomElement() ?? .unknownError
        }
        
        // Mock Entity 생성
        let userEntity = UserEntity(
            id: UUID().uuidString,
            name: "테스트 사용자",
            email: request.email
        )
        
        let loginDataEntity = LoginDataEntity(
            user: userEntity,
            accessToken: generateMockJWTToken(),
            refreshToken: generateMockJWTToken(),
            expiresIn: 3600, // 1시간
            tokenType: "Bearer"
        )
        
        // Entity -> Model 변환
        return loginDataEntity.map()
    }
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 회원가입
    func signUp(_ request: SignUpRequest) async throws -> SignUpResponse {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(for: .seconds(Int.random(in: 1...3)))
        
        // 랜덤 성공/실패 (85% 성공률)
        let shouldSucceed = Bool.random() ? true : (Bool.random() ? true : (Bool.random() ? true : (Bool.random() ? true : false)))
        
        if !shouldSucceed {
            // 랜덤 실패 케이스
            let errors: [AuthError] = [.emailAlreadyExists, .weakPassword, .networkError, .serverError("서버 오류")]
            throw errors.randomElement() ?? .unknownError
        }
        
        // Mock Entity 생성
        let userEntity = UserEntity(
            id: UUID().uuidString,
            name: request.name,
            email: request.email
        )
        
        let signUpDataEntity = SignUpDataEntity(
            user: userEntity,
            message: "회원가입이 완료되었습니다."
        )
        
        // Entity -> Model 변환
        return signUpDataEntity.map()
    }
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 토큰 갱신
    func refreshToken(_ request: RefreshTokenRequest) async throws -> RefreshTokenResponse {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(for: .seconds(Int.random(in: 1...2)))
        
        // 랜덤 성공/실패 (90% 성공률)
        let shouldSucceed = Bool.random() ? true : (Bool.random() ? true : (Bool.random() ? true : (Bool.random() ? true : (Bool.random() ? true : false))))
        
        if !shouldSucceed {
            // 랜덤 실패 케이스
            let errors: [AuthError] = [.refreshTokenExpired, .tokenInvalid, .networkError]
            throw errors.randomElement() ?? .unknownError
        }
        
        // Mock Entity 생성
        let refreshTokenDataEntity = RefreshTokenDataEntity(
            accessToken: generateMockJWTToken(),
            refreshToken: generateMockJWTToken(),
            expiresIn: 3600
        )
        
        // Entity -> Model 변환
        return refreshTokenDataEntity.map()
    }
    
    // MARK: - Private Methods
    
    private func generateMockJWTToken() -> String {
        // Mock JWT 토큰 생성 (실제 JWT 형식)
        let header = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        
        let currentTime = Date().timeIntervalSince1970
        let expirationTime = currentTime + 3600 // 1시간 후 만료
        
        let payload = [
            "sub": UUID().uuidString,
            "exp": Int(expirationTime),
            "iat": Int(currentTime)
        ] as [String : Any]
        
        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            return "mock.jwt.token"
        }
        
        let payloadBase64 = payloadData.base64EncodedString().replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        let signature = "mock_signature_\(UUID().uuidString.prefix(16))"
        
        return "\(header).\(payloadBase64).\(signature)"
    }
}
