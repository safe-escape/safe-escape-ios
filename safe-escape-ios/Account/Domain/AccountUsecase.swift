//
//  AccountUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

class AccountUsecase {
    static let shared = AccountUsecase()
    
    private init() {}
    
    private let userDefaultsKey = "isAutoLoginEnabled"
    
    // MARK: - Authentication Methods
    
    // 로그인
    func login(_ request: LoginRequest) async throws -> LoginResponse {
        let response = try await AccountRepository.shared.login(request)
        
        // 토큰 저장
        TokenStorage.shared.saveTokens(response.tokens)
        
        // 자동 로그인 활성화
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
        
        return response
    }
    
    // 회원가입
    func signUp(_ request: SignUpRequest) async throws -> SignUpResponse {
        let response = try await AccountRepository.shared.signUp(request)
        
        // 회원가입 성공 시 자동 로그인은 하지 않음
        // 사용자가 직접 로그인해야 함
        
        return response
    }
    
    // 로그아웃
    func logout() {
        // 토큰 삭제
        TokenStorage.shared.clearTokens()
        
        // 자동 로그인 비활성화
        UserDefaults.standard.set(false, forKey: userDefaultsKey)
    }
    
    // 자동 로그인 체크
    func checkAutoLogin() -> Bool {
        // UserDefaults에서 자동 로그인 설정 확인
        let isAutoLoginEnabled = UserDefaults.standard.bool(forKey: userDefaultsKey)
        
        // 자동 로그인이 비활성화되어 있으면 false
        guard isAutoLoginEnabled else { return false }
        
        // 저장된 토큰이 있는지 확인
        guard TokenStorage.shared.hasValidTokens() else {
            // 토큰이 없으면 자동 로그인 비활성화
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
            return false
        }
        
        // 액세스 토큰 만료 확인
        if let accessToken = TokenStorage.shared.getAccessToken(),
           TokenStorage.shared.isTokenExpired(accessToken) {
            // 액세스 토큰이 만료된 경우, 리프레시 토큰으로 갱신 시도
            return handleTokenRefresh()
        }
        
        return true
    }
    
    // 토큰 갱신
    func refreshToken() async throws -> Bool {
        guard let refreshToken = TokenStorage.shared.getRefreshToken() else {
            throw AuthError.refreshTokenExpired
        }
        
        // 리프레시 토큰 만료 확인
        if TokenStorage.shared.isTokenExpired(refreshToken) {
            TokenStorage.shared.clearTokens()
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
            throw AuthError.refreshTokenExpired
        }
        
        do {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response = try await AccountRepository.shared.refreshToken(request)
            
            // 새로운 토큰 저장
            let newTokens = TokenModel(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken ?? refreshToken, // 새 리프레시 토큰이 없으면 기존 것 사용
                expiresIn: response.expiresIn
            )
            
            TokenStorage.shared.saveTokens(newTokens)
            return true
            
        } catch {
            // 토큰 갱신 실패 시 로그아웃 처리
            logout()
            throw error
        }
    }
    
    // MARK: - User Info
    
    // 현재 사용자 정보 조회 (토큰에서 추출)
    func getCurrentUser() -> User? {
        // 실제 구현에서는 저장된 사용자 정보나 토큰에서 사용자 정보를 추출
        // 현재는 Mock 데이터 반환
        guard TokenStorage.shared.hasValidTokens() else { return nil }
        
        // TODO: 실제로는 서버에서 사용자 정보를 가져오거나 토큰에서 추출
        return User(
            id: "mock_user_id",
            name: "사용자",
            email: "test@example.com"
        )
    }
    
    // MARK: - Private Methods
    
    private func handleTokenRefresh() -> Bool {
        // 동기적으로 토큰 갱신 상태만 확인
        // 실제 갱신은 비동기로 처리해야 함
        guard let refreshToken = TokenStorage.shared.getRefreshToken() else {
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
            return false
        }
        
        // 리프레시 토큰도 만료되었다면 자동 로그인 불가
        if TokenStorage.shared.isTokenExpired(refreshToken) {
            TokenStorage.shared.clearTokens()
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
            return false
        }
        
        // 리프레시 토큰이 유효하면 자동 로그인 가능
        // (실제 토큰 갱신은 필요할 때 비동기로 수행)
        return true
    }
}
