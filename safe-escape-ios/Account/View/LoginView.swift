//
//  LoginView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/31/25.
//

import SwiftUI

struct AccountTextField: View {
    var label: String
    var placeHolder: String
    @Binding var text: String
    var textContentType: UITextContentType = .name
    var keyboardType: UIKeyboardType = .default
    @FocusState var focusedField: Field?
    var fieldType: Field
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.notosans(type: .regular, size: 11))
                .foregroundStyle(Color.font1E1E1E)
            
            TextField(placeHolder, text: $text)
                .font(.notosans(type: .regular, size: 12))
                .foregroundStyle(Color.font1E1E1E)
                .textContentType(textContentType)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.borderD9D9D9)
                )
                .focused($focusedField, equals: fieldType)
                .submitLabel(submitLabel)
                .onSubmit {
                    onSubmit()
                }
        }
    }
}

struct AccountSecureField: View {
    var label: String
    var placeHolder: String
    @Binding var text: String
    @FocusState var focusedField: Field?
    var fieldType: Field
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.notosans(type: .regular, size: 11))
                .foregroundStyle(Color.font1E1E1E)
            
            SecureField(text: $text) {
                Text(placeHolder)
                    .font(.notosans(type: .regular, size: 12))
            }
            .font(.system(size: 14))
            .textContentType(.password)
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderD9D9D9)
            )
            .focused($focusedField, equals: fieldType)
            .submitLabel(submitLabel)
            .onSubmit {
                onSubmit()
            }
        }
    }
}

// MARK: - Focus Enum
enum Field {
    case email
    case name
    case password
    case confirmPassword
}

struct LoginView: View {
    @ObservedObject var viewModel: AccountViewModel
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 70) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 101)
            
            VStack(spacing: 24) {
                // 이메일
                AccountTextField(label: "이메일", placeHolder: "이메일을 입력하세요", text: $viewModel.loginEmail, textContentType: .emailAddress, keyboardType: .emailAddress, focusedField: _focusedField, fieldType: .email) {
                    focusedField = .password
                }
                
                // 패스워드
                AccountSecureField(label: "비밀번호", placeHolder: "비밀번호를 입력하세요", text: $viewModel.loginPassword, focusedField: _focusedField, fieldType: .password) {
                    Task { await login() }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.notosans(type: .regular, size: 12))
                        .foregroundColor(.pointRed)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                        .padding(.top, -10)
                        .padding(.bottom, -5)
                }
            
                // Login Button
                Button {
                    Task { await login() }
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("로그인")
                        
                        Spacer()
                    }
                    .font(.notosans(type: .regular, size: 13))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .background(viewModel.isLoading ? Color.dimC5D6Ca : Color.accent)
                    .cornerRadius(8)
                }
                .buttonStyle(CommonStateButtonStyle())
                .disabled(viewModel.isLoading)
                
                Button {
                    viewModel.showSignUpView()
                } label: {
                    Text("회원가입하기")
                        .font(.notosans(type: .regular, size: 13))
                        .underline()
                        .foregroundStyle(Color.font1E1E1E)
                        .padding(.top, -2)
                        .padding(.bottom, 2)
                }

            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderD9D9D9)
            )
            .padding(.bottom, 90)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Login Logic
    private func login() async {
        hideKeyboard()
        await viewModel.login()
    }
}

// MARK: - 키보드 숨기기 헬퍼
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif

#Preview {
    let viewModel = AccountViewModel()
    viewModel.setAuthManager(AuthenticationManager())
    return LoginView(viewModel: viewModel)
}
