//
//  AccountDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

class AccountDataSource {
    static let shared = AccountDataSource()
    
    private init() {}

    let provider = MoyaProvider<AuthAPI>(plugins: [APICommonPlugin()])
    
    // 로그인
    func login(_ request: LoginRequest) async throws -> LoginDataEntity {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.login(request: request)) { result in
                switch result {
                case .success(let response):
                    let convertResult = EntityConverter<LoginResponseEntity>.convert(response)
                    switch convertResult {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 회원가입
    func signUp(_ request: SignUpRequest) async throws -> SignUpDataEntity {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.register(request: request)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<SignUpResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 로그아웃
    func logout() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.logout) { result in
                switch result {
                case .success(let response):
                    let convertResult = EntityConverter<LogoutResponseEntity>.convertNoData(response)
                    switch convertResult {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 토큰 갱신
    func refreshToken(_ request: RefreshTokenRequest) async throws -> RefreshTokenDataEntity {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.refresh(request: RefreshTokenRequestEntity(refreshToken: request.refreshToken))) { result in
                switch result {
                case .success(let response):
                    let convertResult = EntityConverter<RefreshTokenResponseEntity>.convert(response)
                    switch convertResult {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        // 토큰 갱신 API에서는 JWT 재시도 로직을 적용하지 않음
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 회원 정보 조회
    func getMe() async throws -> MemberDataEntity {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(.getMe) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(with: EntityConverter<MemberResponseEntity>.convert(response))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            // JWT 만료 에러인 경우 자동 토큰 갱신 후 재시도
            if case EntityConverterError.expiredJWT = error {
                _ = try await AccountUsecase.shared.refreshToken()
                return try await getMe()
            } else {
                throw error
            }
        }
    }
}
