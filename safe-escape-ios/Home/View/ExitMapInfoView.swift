//
//  ExitMapInfoView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import SwiftUI

// 혼잡지역 - 비상구 추천
struct ExitMapInfoView: View {
    @ObservedObject var viewModel: ExitInfoViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48)
            
            if viewModel.state != .find {
                // 비상구 찾기 전
                VStack(alignment: .leading, spacing: 0) {
                    Text("혼잡 지역에 있어요 !!")
                        .font(.notosans(type: .semibold, size: 20))
                    
                    Text("빨리 나갈 수 있는 길을 추천해 드릴까요? ")
                        .font(.notosans(type: .regular, size: 10))
                        .padding(.top, 3)
                        .padding(.bottom, 1)
                    
                    Button {
                        guard viewModel.state == .idle else { return }
                        
                        // 비상구 찾기
                        viewModel.findRoute()
                    } label: {
                        HStack(spacing: 3) {
                            Spacer()
                            
                            if viewModel.state == .idle {
                                Text("비상구 추천")
                                    .padding(.bottom, 1)
                            } else {
                                Text("비상구 추천 중")
                                    .padding(.bottom, 1)
                                
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            }
                            
                            Spacer()
                        }
                        .font(.notosans(type: .semibold, size: 15))
                        .foregroundStyle(Color.white)
                        .frame(height: 32)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.accent)
                        )
                    }
                    .padding(.top, 10)
                }
            } else {
                // 비상구 찾은 후
                VStack(alignment: .leading, spacing: 9) {
                    Text("비상구를 추천해드렸어요")
                        .font(.notosans(type: .semibold, size: 20))
                    
                    Text("현재 위치에서 ")
                    + Text(DistanceFormatter.format(viewModel.route?.totalDistance ?? 0))
                        .font(.notosans(type: .bold, size: 10))
                    + Text(" 떨어져 있고, \n걸어서 ")
                    + Text(TimeFormatter.format(viewModel.route?.totalTime ?? 0))
                        .font(.notosans(type: .bold, size: 10))
                    + Text(" 정도 걸립니다")
                }
                .font(.notosans(type: .regular, size: 10))
                .lineSpacing(4)
                .padding(.bottom, 16)
                
                Spacer(minLength: 0)
            }
        }
        .padding(.leading, 11)
        .padding(.trailing, 16)
        .padding(.top, 13)
        .padding(.bottom, 15)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.white)
                .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
        )
        .padding(.leading, 12)
        .padding(.trailing, 15)
        .padding(.bottom, 13)
        .onAppear {
            viewModel.load()
        }
    }
    
}
