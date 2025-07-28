//
//  HeaderView.swift
//  safe-escape-ios
//
//  Created by Cindy on 7/27/25.
//

import SwiftUI

// 공통 헤더 뷰
struct HeaderView: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 23)
            
            Image(.sloganHeader)
                .padding(.bottom, 1)
            
            Spacer()
        }
        .padding(.leading, 20)
        .frame(height: 60)
        .background(.backgroundF7F7F7)
    }
}

#Preview {
    HeaderView()
}
