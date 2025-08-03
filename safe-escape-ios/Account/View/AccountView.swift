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
            } else {
                LoginView(viewModel: viewModel)
                    .navigationDestination(isPresented: $viewModel.showSignUp) {
                        SignUpView(viewModel: viewModel)
                    }
            }
        }
        .onAppear {
            viewModel.setAuthManager(authManager)
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthenticationManager())
}
