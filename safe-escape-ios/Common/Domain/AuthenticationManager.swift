//
//  AuthenticationManager.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async -> Result<Void, AuthError> {
        do {
            let request = LoginRequest(email: email, password: password)
            let response = try await AccountUsecase.shared.login(request)
            
            await MainActor.run {
                self.isLoggedIn = true
                self.currentUser = response.user
            }
            
            return .success(())
            
        } catch let error as AuthError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
    func signUp(name: String, email: String, password: String) async -> Result<Void, AuthError> {
        do {
            let request = SignUpRequest(name: name, email: email, password: password)
            _ = try await AccountUsecase.shared.signUp(request)
            
            // 회원가입 성공 시 자동 로그인 처리 (사용자 정보는 이미 캐시됨)
            await MainActor.run {
                self.isLoggedIn = true
                self.currentUser = AccountUsecase.shared.getCurrentUser()
            }
            
            return .success(())
            
        } catch let error as AuthError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
    func logout() async {
        await AccountUsecase.shared.logout()
        
        await MainActor.run {
            self.isLoggedIn = false
            self.currentUser = nil
        }
    }
    
    func checkAutoLogin() async {
        let canAutoLogin = await AccountUsecase.shared.checkAutoLogin()
        
        await MainActor.run {
            if canAutoLogin {
                // 자동 로그인 성공한 경우 (이미 사용자 정보가 캐시됨)
                self.isLoggedIn = true
                self.currentUser = AccountUsecase.shared.getCurrentUser()
            } else {
                self.isLoggedIn = false
                self.currentUser = nil
            }
        }
    }
}

