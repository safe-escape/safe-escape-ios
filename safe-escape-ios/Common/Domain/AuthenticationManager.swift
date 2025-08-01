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
            
            // 회원가입만 처리하고 자동 로그인하지 않음
            // 로그인 화면에서 사용자가 직접 로그인해야 함
            
            return .success(())
            
        } catch let error as AuthError {
            return .failure(error)
        } catch {
            return .failure(.unknownError)
        }
    }
    
    func logout() {
        AccountUsecase.shared.logout()
        
        isLoggedIn = false
        currentUser = nil
    }
    
    func checkAutoLogin() {
        let canAutoLogin = AccountUsecase.shared.checkAutoLogin()
        
        if canAutoLogin {
            // 자동 로그인 가능한 경우 사용자 정보 복원
            isLoggedIn = true
            currentUser = AccountUsecase.shared.getCurrentUser()
        } else {
            isLoggedIn = false
            currentUser = nil
        }
    }
}

