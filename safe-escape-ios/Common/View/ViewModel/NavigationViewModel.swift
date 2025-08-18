//
//  NavigationViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/18/25.
//

import SwiftUI

// 전체 앱 네비게이션 관장 뷰모델
class NavigationViewModel: ObservableObject {
    
    @Published var page: Page = .home
    var data: Any?
    
    // 특정 페이지로 이동
    func navigate(_ page: Page, _ data: Any? = nil) {
        self.data = data
        self.page = page
    }
}


