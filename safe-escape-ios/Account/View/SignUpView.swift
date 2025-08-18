//
//  SignUpView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/31/25.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AccountViewModel
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 101)
            
            VStack(spacing: 24) {
                // 이름
                AccountTextField(label: "이름", placeHolder: "이름을 입력하세요", text: $viewModel.signUpName, textContentType: .name, focusedField: _focusedField, fieldType: .name) {
                    focusedField = .email
                }
                
                // 이메일
                AccountTextField(label: "이메일", placeHolder: "이메일을 입력하세요", text: $viewModel.signUpEmail, textContentType: .emailAddress, keyboardType: .emailAddress, focusedField: _focusedField, fieldType: .email) {
                    focusedField = .password
                }
                
                // 패스워드
                AccountSecureField(label: "비밀번호", placeHolder: "비밀번호를 입력하세요", text: $viewModel.signUpPassword, focusedField: _focusedField, fieldType: .password) {
                    focusedField = .confirmPassword
                }
                
                // 패스워드 확인
                AccountSecureField(label: "비밀번호 확인", placeHolder: "비밀번호를 다시 입력하세요", text: $viewModel.signUpConfirmPassword, focusedField: _focusedField, fieldType: .confirmPassword, submitLabel: .done) {
                    Task { await signUp() }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.notosans(type: .regular, size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                        .padding(.top, -10)
                        .padding(.bottom, -5)
                }
            
                // SignUp Button
                Button {
                    Task { await signUp() }
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("회원가입")
                        
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
                

            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderD9D9D9)
            )
        }
        .padding(.horizontal, 28)
        .animation(.easeInOut(duration: 0.3), value: focusedField)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.showSignUp) { newValue in
            if !newValue {
                dismiss()
            }
        }
    }

    // MARK: - SignUp Logic
    private func signUp() async {
        hideKeyboard()
        await viewModel.signUp()
    }
}

#Preview {
    let viewModel = AccountViewModel()
    viewModel.setAuthManager(AuthenticationManager())
    return SignUpView(viewModel: viewModel)
}
