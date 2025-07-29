//
//  ShelterView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import SwiftUI

struct ShelterView: View {
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("내 주변 대피소")
                        .font(.notosans(type: .bold, size: 20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("주변에 총 ")
                    + Text("6개")
                        .font(.notosans(type: .bold, size: 15))
                        .foregroundColor(Color.pointRed)
                    + Text("의 대피소가 있어요 !")
                    
                    
                    
                    Spacer()
                }
                .font(.notosans(type: .regular, size: 15))
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .frame(minHeight: maxHeight - 60)
            }
        }
        .background(Color.backgroundF7F7F7)
    }
}

#Preview {
    ShelterView()
}
