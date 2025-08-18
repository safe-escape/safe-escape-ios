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
        do {
            let response = try await AccountRepository.shared.login(request)
            
            // 토큰 저장
            TokenStorage.shared.saveTokens(response.tokens)
            
            // 자동 로그인 활성화
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
            
            // 로그인 시 사용자 정보 캐시
            cachedUser = response.user
            
            return response
            
        } catch {
            // 로그인 관련 에러 처리
            if case EntityConverterError.apiError(let code, _) = error {
                switch code.uppercased() {
                case "INVALID_PASSWORD":
                    throw AuthError.invalidCredentials
                case "INVALID_EMAIL":
                    throw AuthError.invalidCredentials
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
    }
    
    // 회원가입
    func signUp(_ request: SignUpRequest) async throws -> SignUpResponse {
        do {
            let response = try await AccountRepository.shared.signUp(request)
            
            // 회원가입 성공 시 자동 로그인 처리
            let tokens = TokenModel(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: 3600 // 1시간, 실제로는 서버에서 받아야 함
            )
            
            // 토큰 저장
            TokenStorage.shared.saveTokens(tokens)
            
            // 자동 로그인 활성화
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
            
            // 회원가입 시 실시간 사용자 정보 조회 및 캐시
            let user = try await AccountRepository.shared.getMe()
            cachedUser = user
            
            return response
            
        } catch {
            // EMAIL_ALREADY_REGISTERED 에러 처리
            if case EntityConverterError.apiError(let code, _) = error,
               code.uppercased() == "EMAIL_ALREADY_REGISTERED" {
                throw AuthError.emailAlreadyExists
            } else {
                throw error
            }
        }
    }
    
    // 로그아웃
    func logout() async {
        // 서버에 로그아웃 API 호출
        do {
            try await AccountRepository.shared.logout()
        } catch {
            // 로그아웃 API 실패해도 로컬 정리는 진행
            print("로그아웃 API 호출 실패: \(error)")
        }
        
        // 토큰 삭제
        TokenStorage.shared.clearTokens()
        
        // 자동 로그인 비활성화
        UserDefaults.standard.set(false, forKey: userDefaultsKey)
        
        // 사용자 정보 캐시 초기화
        clearUserCache()
    }
    
    // 자동 로그인 체크 (비동기)
    func checkAutoLogin() async -> Bool {
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
            let refreshSuccess = await handleTokenRefreshAsync()
            if !refreshSuccess {
                return false
            }
        }
        
        // 자동 로그인 시 실시간 사용자 정보 조회 및 캐시
        do {
            let user = try await AccountRepository.shared.getMe()
            cachedUser = user
        } catch {
            // 사용자 정보 조회 실패 시 자동 로그인 실패
            clearUserCache()
            return false
        }
        
        return true
    }
    
    // 동기 방식 자동 로그인 체크 (기존 호환성을 위해)
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
            // EXPIRED_REFRESH_TOKEN 에러인 경우 특별 처리
            if case EntityConverterError.expiredRefreshToken = error {
                // 로그아웃 및 알림 표시
                await handleExpiredRefreshToken()
                throw AuthError.refreshTokenExpired
            } else {
                // 토큰 갱신 실패 시 로그아웃 처리
                await logout()
                throw error
            }
        }
    }
    
    // MARK: - User Info
    
    // 캐시된 사용자 정보 저장소
    private var cachedUser: User? = nil
    
    // 현재 사용자 정보 조회 (캐시 우선, 없으면 실시간 조회)
    func getCurrentUser() async throws -> User? {
        guard TokenStorage.shared.hasValidTokens() else { return nil }
        
        // 캐시된 사용자 정보가 있으면 반환
        if let cachedUser = cachedUser {
            return cachedUser
        }
        
        // 캐시된 정보가 없으면 실시간으로 조회하고 캐시
        let user = try await AccountRepository.shared.getMe()
        cachedUser = user
        return user
    }
    
    // 동기 방식으로 캐시된 사용자 정보만 조회
    func getCurrentUser() -> User? {
        guard TokenStorage.shared.hasValidTokens() else { return nil }
        return cachedUser
    }
    
    // 사용자 정보 캐시 초기화 (로그아웃 시 호출)
    private func clearUserCache() {
        cachedUser = nil
    }
    
    // MARK: - Private Methods
    
    // 비동기 토큰 갱신
    private func handleTokenRefreshAsync() async -> Bool {
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
        
        // 실제 토큰 갱신 시도
        do {
            _ = try await self.refreshToken()
            return true
        } catch {
            await logout()
            return false
        }
    }
    
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
    
    // EXPIRED_REFRESH_TOKEN 에러 처리
    private func handleExpiredRefreshToken() async {
        // 로그아웃 처리
        await logout()
        
        // 메인 스레드에서 UI 업데이트
        await MainActor.run {
            // 알림 표시
            // TODO: 실제 알림 표시 로직 구현 ("다시 로그인해주세요.")
            
            // 로그인 페이지로 이동
            // TODO: 네비게이션 로직 구현
            NotificationCenter.default.post(name: .expiredRefreshToken, object: nil)
        }
    }
}

extension Notification.Name {
    static let expiredRefreshToken = Notification.Name("expiredRefreshToken")
}
