//
//  TabBarView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI

// 탭뷰 하단 탭바 뷰
struct TabBarView: View {
    @Binding var currentPage: Page // 현재 선택한 페이지
    var tabs: [Tab] // 탭 리스트
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(tabs, id: \.page) { tab in
                TabBarItemView(model: tab, selected: currentPage == tab.page, currentPage: $currentPage)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
        .frame(height: 50)
        .background(
            // 탭바 shadow
            Color.white
                .shadow(color: .black.opacity(0.16), radius: 6)
        )
    }
}

// 탭뷰 하단 탭바 아이템 뷰
struct TabBarItemView: View {
    var model: Tab
    var selected: Bool // 선택되었는지 여부
    @Binding var currentPage: Page // 현재 선택된 페이지
    
    var body: some View {
        VStack(spacing: 2) {
            Spacer()
            
            // 탭 아이콘
            Image(selected ? model.icon + "_selected" : model.icon)
                .frame(width: 20, height: 20)
            
            // 탭 타이틀
            Text(model.title)
                .font(.notosans(type: selected ? .semibold : .medium, size: 10))
                .foregroundStyle(selected ? Color.accent : Color.font898989)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            // 탭 선택시 해당 탭 페이지로 이동
            currentPage = model.page
        }
    }
}
