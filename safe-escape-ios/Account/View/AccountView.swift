//
//  AccountView.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @StateObject private var viewModel = AccountViewModel()
    
    var body: some View {
        NavigationStack {
            if authManager.isLoggedIn {
                MyPageView(accountViewModel: viewModel)
                    .transition(.opacity)
            } else {
                LoginView(viewModel: viewModel)
                    .transition(.opacity)
                    .navigationDestination(isPresented: $viewModel.showSignUp) {
                        SignUpView(viewModel: viewModel)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
        .onAppear {
            viewModel.setAuthManager(authManager)
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthenticationManager())
}
