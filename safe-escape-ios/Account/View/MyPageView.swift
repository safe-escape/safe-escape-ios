//
//  MyPageView.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI
import SkeletonUI

struct MyPageView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @ObservedObject var accountViewModel: AccountViewModel
    @StateObject private var viewModel = MyPageViewModel()
    
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(backgroundColor: .white)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 사용자 정보 카드
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentUser?.name ?? "")
                                .font(.notosans(type: .semibold, size: 24))
                            + Text(" 님 안녕하세요.")
                                .font(.notosans(type: .regular, size: 24))
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(.notosans(type: .regular, size: 14))
                        }
                        
                        Spacer(minLength: 0)
                        
                        Text("로그아웃")
                            .font(.notosans(type: .bold, size: 13))
                            .underline()
                            .onTapGesture {
                                accountViewModel.logout()
                            }
                            .padding(.top, 5)
                    }
                    .foregroundStyle(Color.white)
                    .padding(20)
                    .padding(.leading, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.accent)
                    )
                    .padding(.horizontal, 20)
                    
                    // 찜한 대피소 섹션
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 0) {
                            Text("내가 저장한 대피소 ")
                            
                            if !viewModel.isLoading {
                                Text("(\(viewModel.favoriteShelters.count))")
                            }
                            
                            Spacer()
                        }
                        .font(.notosans(type: .bold, size: 20))
                        .foregroundStyle(Color.font1E1E1E)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        if !viewModel.isLoading && viewModel.favoriteShelters.isEmpty {
                            // 빈 상태
                            VStack(spacing: 8) {
                                Spacer()
                                
                                Image(systemName: "heart")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                    .padding(.bottom, 2)
                                
                                Text("찜한 대피소가 없습니다")
                                    .font(.notosans(type: .medium, size: 16))
                                
                                Text("지도에서 대피소를 찜해보세요!")
                                    .font(.notosans(type: .regular, size: 14))
                                    .padding(.bottom, maxHeight / 6)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.accent.opacity(0.6))
                        } else {
                            // 찜한 대피소 목록 (로딩 상태 포함)
                            VStack(spacing: 0) {
                                SkeletonForEach(with: viewModel.favoriteShelters, quantity: viewModel.isLoading ? 3 : viewModel.favoriteShelters.count) { _, shelter in
                                    ShelterListItemView(shelter: shelter, isLoading: viewModel.isLoading) {
                                        guard let shelter else { return }
                                        // 찜한 대피소 탭 동작 (예: 지도로 이동)
                                        print("Favorite shelter tapped: \(shelter.name)")
                                        
                                        navigationViewModel.navigate(.home, shelter)
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        
                                        Button {
                                            guard let shelter else {
                                                return
                                            }
                                            viewModel.toggleShelterFavorite(shelter)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10)
                                                .padding(6)
                                                .contentShape(Rectangle())
                                                .foregroundStyle(.gray)
                                        }
                                            .padding(.top, 21)
                                            .padding(.trailing, 6)
                                            .opacity(viewModel.isLoading ? 0 : 1)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(minHeight: maxHeight - 180)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.backgroundF7F7F7)
                            .padding(.bottom, -30)
                    )
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    let authManager = AuthenticationManager()
    authManager.currentUser = User(id: "", name: "김가슬", email: "dtrbu123@naver.com")
    let accountViewModel = AccountViewModel()
    accountViewModel.setAuthManager(authManager)
    
    return MyPageView(accountViewModel: accountViewModel)
        .environmentObject(authManager)
        .environmentObject(NavigationViewModel())
}
