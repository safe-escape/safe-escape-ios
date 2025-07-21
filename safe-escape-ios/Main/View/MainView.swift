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
                    // TODO: 페이지 생성 시 추가 필요
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.bottom, 40)
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
