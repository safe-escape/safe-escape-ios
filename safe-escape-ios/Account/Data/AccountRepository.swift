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
    
    // 로그인
    func login(_ request: LoginRequest) async throws -> LoginResponse {
        return try await AccountDataSource.shared.login(request).map()
    }
    
    // 회원가입
    func signUp(_ request: SignUpRequest) async throws -> SignUpResponse {
        return try await AccountDataSource.shared.signUp(request).map()
    }
    
    // 로그아웃
    func logout() async throws {
        _ = try await AccountDataSource.shared.logout()
    }
    
    // 회원 정보 조회
    func getMe() async throws -> User {
        return try await AccountDataSource.shared.getMe().map()
    }
    
    // 토큰 갱신
    func refreshToken(_ request: RefreshTokenRequest) async throws -> RefreshTokenResponse {
        return try await AccountDataSource.shared.refreshToken(request).map()
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
