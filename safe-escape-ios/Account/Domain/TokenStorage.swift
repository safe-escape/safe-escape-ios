//
//  TokenStorage.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation
import Security

// JWT 토큰 저장소 (Keychain 사용)
class TokenStorage {
    static let shared = TokenStorage()
    
    private init() {}
    
    private let service = "com.safe-escape.tokens"
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    
    // MARK: - Token Storage
    
    func saveTokens(_ tokens: TokenModel) {
        saveToken(tokens.accessToken, key: accessTokenKey)
        saveToken(tokens.refreshToken, key: refreshTokenKey)
    }
    
    func getAccessToken() -> String? {
        return getToken(key: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return getToken(key: refreshTokenKey)
    }
    
    func clearTokens() {
        deleteToken(key: accessTokenKey)
        deleteToken(key: refreshTokenKey)
    }
    
    // MARK: - Private Keychain Methods
    
    private func saveToken(_ token: String, key: String) {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getToken(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    private func deleteToken(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Token Validation

extension TokenStorage {
    
    // 토큰 존재 여부 확인
    func hasValidTokens() -> Bool {
        return getAccessToken() != nil && getRefreshToken() != nil
    }
    
    // JWT 토큰 만료 여부 확인 (간단한 구현)
    func isTokenExpired(_ token: String) -> Bool {
        let components = token.components(separatedBy: ".")
        guard components.count == 3 else { return true }
        
        let payload = components[1]
        guard let data = base64UrlDecode(payload) else { return true }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let exp = json["exp"] as? TimeInterval {
                let expirationDate = Date(timeIntervalSince1970: exp)
                return expirationDate <= Date()
            }
        } catch {
            print("JWT 파싱 실패: \(error)")
        }
        
        return true
    }
    
    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}