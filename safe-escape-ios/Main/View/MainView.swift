//
//  MainView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/17/25.
//

import SwiftUI

struct MainView: View {
    @State var viewModel: MainViewModel = MainViewModel()
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        VStack {
            TabView(selection: $navigationViewModel.page) {
                ForEach(viewModel.tabs, id: \.page) { tab in
                    switch tab.page {
                    case .home:
                        HomeView()
                            .tag(tab.page)
                            .ignoresSafeArea(.keyboard)
                    case .crowded:
                        CrowdedView()
                            .tag(tab.page)
                    case .shelter:
                        ShelterView()
                            .tag(tab.page)
                    case .mypage:
                        AccountView()
                            .tag(tab.page)
                    default:
                        VStack {
                            Spacer()
                        }
                        .tag(tab.page)
                    }
                }
            }
            .tabViewStyle(.automatic)
            .overlay(alignment: .bottom) {
                // 탭바
                TabBarView(currentPage: $navigationViewModel.page, tabs: viewModel.tabs)
            }
        }
        .padding(.bottom, safeAreaBottom)
        .overlay(
            // 탭바 하단 shadow safe area 영역에서 안보이도록 처리
            Rectangle()
                .frame(height: safeAreaBottom)
                .foregroundStyle(Color.white)
            , alignment: .bottom)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    MainView()
        .environmentObject(NavigationViewModel())
}
