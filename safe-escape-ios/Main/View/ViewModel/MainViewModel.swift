//
//  MainViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI

// 메인 뷰 모델
class MainViewModel: ObservableObject {
    
    // 탭뷰 탭바 탭
    let tabs: [Tab] = [
        Tab(page: .home, title: "홈", icon: "home_tab"),
        Tab(page: .congestion, title: "혼잡도", icon: "congestion_tab"),
        Tab(page: .shelter, title: "대피소", icon: "shelter_tab"),
        Tab(page: .mypage, title: "마이", icon: "mypage_tab"),
    ]
    
}
