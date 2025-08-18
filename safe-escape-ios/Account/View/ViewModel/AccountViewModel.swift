//
//  AccountViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI

class AccountViewModel: ObservableObject {
    // MARK: - UI State
    @Published var showSignUp: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Login Fields
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""
    
    // SignUp Fields
    @Published var signUpName: String = ""
    @Published var signUpEmail: String = ""
    @Published var signUpPassword: String = ""
    @Published var signUpConfirmPassword: String = ""
    
    // Dependencies
    private var authManager: AuthenticationManager!
    
    func setAuthManager(_ authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    // MARK: - Actions
    
    func login() async {
        guard validateLoginInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let result = await authManager.login(email: loginEmail, password: loginPassword)
        
        await MainActor.run {
            isLoading = false
            
            switch result {
            case .success():
                clearLoginFields()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp() async {
        guard validateSignUpInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let result = await authManager.signUp(name: signUpName, email: signUpEmail, password: signUpPassword)
        
        await MainActor.run {
            isLoading = false
            
            switch result {
            case .success():
                // 회원가입 성공 시 자동 로그인이므로 해당 뷰 닫기
                clearSignUpFields()
                showSignUp = false
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func logout() {
        Task {
            await authManager.logout()
            await MainActor.run {
                clearAllFields()
            }
        }
    }
    
    func showSignUpView() {
        showSignUp = true
        errorMessage = nil
    }
    
    func hideSignUpView() {
        showSignUp = false
        errorMessage = nil
        clearSignUpFields()
    }
    
    // MARK: - Validation
    
    private func validateLoginInput() -> Bool {
        if loginEmail.isEmpty || loginPassword.isEmpty {
            errorMessage = "이메일과 비밀번호를 입력해주세요"
            return false
        }
        
        if !isValidEmail(loginEmail) {
            errorMessage = "올바른 이메일 형식을 입력해주세요"
            return false
        }
        
        return true
    }
    
    private func validateSignUpInput() -> Bool {
        if signUpName.isEmpty || signUpEmail.isEmpty || signUpPassword.isEmpty || signUpConfirmPassword.isEmpty {
            errorMessage = "모든 필드를 입력해주세요"
            return false
        }
        
        if !isValidEmail(signUpEmail) {
            errorMessage = "올바른 이메일 형식을 입력해주세요"
            return false
        }
        
        if signUpPassword != signUpConfirmPassword {
            errorMessage = "비밀번호가 일치하지 않습니다"
            return false
        }
        
        if signUpPassword.count < 4 {
            errorMessage = "비밀번호는 4자 이상이어야 합니다"
            return false
        }
        
        if signUpPassword.contains(" ") {
            errorMessage = "비밀번호에는 공백을 포함할 수 없습니다"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Helper Methods
    
    private func clearLoginFields() {
        loginEmail = ""
        loginPassword = ""
    }
    
    private func clearSignUpFields() {
        signUpName = ""
        signUpEmail = ""
        signUpPassword = ""
        signUpConfirmPassword = ""
    }
    
    private func clearAllFields() {
        clearLoginFields()
        clearSignUpFields()
        showSignUp = false
        errorMessage = nil
    }
}
