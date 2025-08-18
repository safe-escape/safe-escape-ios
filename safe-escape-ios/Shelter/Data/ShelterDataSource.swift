//
//  ShelterDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

class ShelterDataSource {
    static let shared = ShelterDataSource()
    
    private init() {}

    let provider = MoyaProvider<ShelterAPI>(plugins: [APICommonPlugin()])
    
    // 즐겨찾기 대피소 조회
    func getBookmarkedShelters() async throws -> [ShelterBookmarkDataEntity] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(.getBookmarkedShelters) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(with: EntityConverter<ShelterBookmarkResponseEntity>.convert(response))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            // JWT 만료 에러인 경우 자동 토큰 갱신 후 재시도
            if case EntityConverterError.expiredJWT = error {
                _ = try await AccountUsecase.shared.refreshToken()
                return try await getBookmarkedShelters()
            } else {
                throw error
            }
        }
    }
    
    // 대피소 찜하기 (POST)
    func addBookmark(shelterId: Int) async throws -> ShelterBookmarkDataEntity {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(.addBookmark(shelterId: shelterId)) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(with: EntityConverter<ShelterBookmarkAddResponseEntity>.convert(response))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            // JWT 만료 에러인 경우 자동 토큰 갱신 후 재시도
            if case EntityConverterError.expiredJWT = error {
                _ = try await AccountUsecase.shared.refreshToken()
                return try await addBookmark(shelterId: shelterId)
            } else {
                throw error
            }
        }
    }
    
    // 대피소 찜 해제 (DELETE)
    func removeBookmark(shelterId: Int) async throws -> Bool {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(.removeBookmark(shelterId: shelterId)) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(with: EntityConverter<ShelterBookmarkRemoveResponseEntity>.convertNoData(response))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            // JWT 만료 에러인 경우 자동 토큰 갱신 후 재시도
            if case EntityConverterError.expiredJWT = error {
                _ = try await AccountUsecase.shared.refreshToken()
                return try await removeBookmark(shelterId: shelterId)
            } else {
                throw error
            }
        }
    }
}