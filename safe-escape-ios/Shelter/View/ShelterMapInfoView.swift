//
//  ShelterMapInfoView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/25/25.
//

import SwiftUI

// 홈 지도 - 대피소 정보 오버레이 뷰
struct ShelterMapInfoView: View {
    @ObservedObject var viewModel: ShelterInfoViewModel
    
    // 뷰 표시 여부
    @Binding var show: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                // 마커 이미지
                Image(.shelterMarker)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48)
                
                Circle()
                    .foregroundStyle(Color.pointRed)
                    .frame(width: 10)
                    .padding(.top, 4)
                
                // 거리
                Text(DistanceFormatter.format(viewModel.shelter.distance))
                    .font(.notosans(type: .semibold, size: 10))
                    .padding(.top, 8)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 3) {
                    // 이름
                    Text(viewModel.shelter.name)
                        .font(.notosans(type: .semibold, size: 20))
                    
                    // TODO: 회원인 경우에만 보여주도록 변경 및 이름 라인 변경 시 처리
                    // 찜 버튼
                    Image(systemName: viewModel.liked ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.liked ? Color.pointRed : Color.black)
                        .onTapGesture {
                            viewModel.toggleLiked()
                        }
                        .padding(.bottom, 5)
                }
                
                // 주소
                Text(viewModel.shelter.address)
                    .font(.notosans(type: .regular, size: 10))
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                
                if viewModel.route == nil {
                    // 경로 찾기 전인 경우, 길찾기 버튼 노출
                    Button {
                        guard !viewModel.loading else { return }
                        
                        viewModel.findRoute()
                    } label: {
                        HStack(spacing: 3) {
                            Spacer()
                            
                            // 로더 처리
                            if viewModel.loading {
                                Text("길찾는 중")
                                    .padding(.bottom, 1)
                                
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                                
                            } else {
                                Text("길찾기")
                                    .padding(.bottom, 1)
                            }
                            
                            Spacer()
                        }
                        .font(.notosans(type: .semibold, size: 15))
                        .foregroundStyle(Color.white)
                        .frame(height: 34)
                        .contentShape(Rectangle())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.pointRed)
                        )
                    }
                    .padding(.top, 10)
                } else {
                    // 경로 있는 경우, 대피소까지 도보 거리/소요 시간 노출
                    HStack {
                        Text("현재 위치에서 ")
                        + Text(DistanceFormatter.format(viewModel.route?.totalDistance ?? 0))
                            .font(.notosans(type: .bold, size: 10))
                        + Text(" 떨어져 있고, \n걸어서 ")
                        + Text(TimeFormatter.format(viewModel.route?.totalTime ?? 0))
                            .font(.notosans(type: .bold, size: 10))
                        + Text(" 정도 걸립니다")
                        
                        Spacer(minLength: 0)
                    }
                    .font(.notosans(type: .regular, size: 10))
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .padding(.bottom, 6)
                }
            }
        }
        .padding(.leading, 11)
        .padding(.trailing, 16)
        .padding(.top, 13)
        .padding(.bottom, 15)
        .frame(minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.white)
                .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
        )
        .overlay(alignment: .topTrailing) {
            // 닫기 버튼
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 10)
                .padding(8)
                .contentShape(Rectangle())
                .onTapGesture {
                    show = false
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
        }
        .padding(.leading, 12)
        .padding(.trailing, 15)
        .padding(.bottom, 13)
    }
    
}
