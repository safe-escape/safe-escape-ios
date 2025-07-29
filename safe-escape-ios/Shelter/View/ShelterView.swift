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
                VStack(alignment: .leading, spacing: 0) {
                    Text("내 주변 대피소")
                        .font(.notosans(type: .bold, size: 20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                    
                    Text("주변에 총 ")
                    + Text("6개")
                        .font(.notosans(type: .bold, size: 15))
                        .foregroundColor(Color.pointRed)
                    + Text("의 대피소가 있어요 !")
                    
                    ForEach(0...5, id: \.self) { _ in
                        HStack(alignment: .top) {
                            VStack(spacing: 2) {
                                Image(.shelterMarker)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 34)
                                    
                                Circle()
                                    .frame(width: 7)
                                    .foregroundStyle(Color.pointRed)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("인수동 자치회관")
                                    .font(.notosans(type: .bold, size: 18))
                                
                                Text("서울특별시 강북구 인수봉로 255")
                                    .font(.notosans(type: .regular, size: 11))
                                    .foregroundStyle(Color.font757575)
                            }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -2)
                            
                            Text("189m")
                                .font(.notosans(type: .semibold, size: 15))
                                .padding(.top, 1)
                        }
                        .padding(.vertical, 24)
                        .padding(.leading, 6)
                        .padding(.trailing, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.borderD7D7D7)
                        )
                        .padding(.top, 15)
                    }
                    
                    Spacer(minLength: 5)
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
