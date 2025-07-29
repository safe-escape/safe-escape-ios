//
//  CrowdedView.swift
//  safe-escape-ios
//
//  Created by Cindy on 7/27/25.
//

import SwiftUI

// 혼잡도 뷰
struct CrowdedView: View {
    @StateObject var viewModel: CrowdedViewModel = CrowdedViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 혼잡도 예상
                    CrowdedExpectView(viewModel: viewModel)
                        .zIndex(2)
                    
                    // 내 주변 혼잡한 지역
                    CrowdedNearByListView(viewModel: viewModel)
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .background(Color.backgroundF7F7F7)
        .onAppear {
            // 데이터 조회
            viewModel.requestData()
        }
    }
}

#Preview {
    CrowdedView()
}
