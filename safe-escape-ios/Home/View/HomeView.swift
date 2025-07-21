//
//  HomeView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        
        return mapView
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        
    }
    
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct HomeView: View {
    
    @State var text: String = ""
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack {
            // TODO: 네이버 지도
            NaverMapView()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TextField("주소 검색", text: $text) {
                        
                    }
                    .focused($isFocused)
                    .font(.notosans(type: .medium, size: 16))
                    .keyboardType(.default)
                    
                    Spacer(minLength: 0)
                    
                    Image(.magnifier)
                        .onTapGesture {
                            // TODO: 검색
                            isFocused = false
                        }
                }
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                )
                .padding(.top, 14)
                .padding(.horizontal, 8)
                
                HStack(alignment: .top, spacing: 0) {
                    Text("🔥 근처에서 우이동이 가장 혼잡해요")
                        .font(.notosans(type: .bold, size: 14))
                        .multilineTextAlignment(.leading)
                        .frame(alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -1)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.init(hex: "eaeaea")!, lineWidth: 1)
                        )
                        .padding(.top, 9)
                        .padding(.leading, 12)
                    
                    Spacer(minLength: 14)
                    
                    Circle()
                        .frame(width: 34)
                        .foregroundStyle(Color.white)
                        .overlay {
                            Image(.currentUserLocation)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                        }
                        .shadow(color: .black.opacity(0.16), radius: 3, x: 0, y: 2)
                        .padding(.top, 15)
                        .padding(.trailing, 15)
                    
                }
                
                Spacer()
                
                // 대피소 정보
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        Image(.shelterMarker)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48)
                        
                        Circle()
                            .foregroundStyle(Color.pointRed)
                            .frame(width: 10)
                            .padding(.top, 4)
                        
                        Text("189m")
                            .font(.notosans(type: .semibold, size: 10))
                            .padding(.top, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("인수동 자치회관")
                                .font(.notosans(type: .semibold, size: 20))
                            
                            Image(systemName: "heart")
                                .padding(.bottom, 4)
                        }
                        
                        Text("서울특별시 강북구 인수봉로 255")
                            .font(.notosans(type: .regular, size: 10))
                            .lineSpacing(3)
                            .padding(.top, 6)
                            .padding(.bottom, 3)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("길찾기")
                                    .font(.notosans(type: .semibold, size: 15))
                                    .foregroundStyle(Color.white)
                                
                                Spacer()
                            }
                            .frame(height: 32)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.pointRed)
                            )
                        }
                        .padding(.top, 10)
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
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10)
                        .padding(8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                }
                .padding(.leading, 12)
                .padding(.trailing, 15)
                .padding(.bottom, 13)
                
                // 혼잡지역 - 비상구 추천
                HStack(alignment: .top, spacing: 12) {
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("혼잡 지역에 있어요 !!")
                            .font(.notosans(type: .semibold, size: 20))
                        
                        Text("빨리 나갈 수 있는 길을 추천해 드릴까요? ")
                            .font(.notosans(type: .regular, size: 10))
                            .padding(.top, 2)
                            .padding(.bottom, 2)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("비상구 추천")
                                    .font(.notosans(type: .semibold, size: 15))
                                    .foregroundStyle(Color.white)
                                
                                Spacer()
                            }
                            .frame(height: 32)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.accent)
                            )
                        }
                        .padding(.top, 10)
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
                
                // 혼잡지역 - 비상구 추천 완료
                HStack(alignment: .top, spacing: 12) {
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48)
                    
                    VStack(alignment: .leading, spacing: 9) {
                        Text("비상구를 추천해드렸어요")
                            .font(.notosans(type: .semibold, size: 20))
                        
                        Text("현재 위치에서 ")
                        + Text("1.8Km")
                            .font(.notosans(type: .bold, size: 10))
                        + Text(" 떨어져 있고, \n걸어서 ")
                        + Text("18분")
                            .font(.notosans(type: .bold, size: 10))
                        + Text(" 정도 걸립니다")
                    }
                    .font(.notosans(type: .regular, size: 10))
                    .lineSpacing(5)
                    .padding(.bottom, 16)
                    
                    Spacer(minLength: 0)
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
            }
        }
    }
}

#Preview {
    HomeView()
}
