//
//  MyPageView.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI

struct MyPageView: View {
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("마이페이지")
                .font(.notosans(type: .bold, size: 24))
                .foregroundStyle(Color.font1E1E1E)
            
            Spacer()
            
            Button("로그아웃") {
                viewModel.logout()
            }
            .font(.notosans(type: .regular, size: 13))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.accent)
            .cornerRadius(8)
            .padding(.horizontal, 28)
            
            Spacer()
        }
        .padding(.top, 50)
    }
}

#Preview {
    let viewModel = AccountViewModel()
    viewModel.setAuthManager(AuthenticationManager())
    return MyPageView(viewModel: viewModel)
}