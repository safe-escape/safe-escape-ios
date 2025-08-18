//
//  HomeView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI

struct HomeView: View {
    @FocusState var inputAddressFocused: Bool
    
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        ZStack {
            // 네이버 지도
            MapView(viewModel: viewModel.mapViewModel)
            
            VStack(spacing: 0) {
                // 주소 검색창
                InputAddressView(viewModel: viewModel.inputAddressViewModel)
                    .padding(.top, 14)
                    .padding(.horizontal, 8)
                
                // 주위 지역 정보 표시
                if let info = viewModel.info {
                    HStack(alignment: .top, spacing: 0) {
                        Text(info)
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // 혼잡도 탭으로 이동
                                navigationViewModel.navigate(.crowded)
                            }
                            .padding(.top, 9)
                            .padding(.leading, 12)
                        
                        Spacer(minLength: 14)
                        
                        // 사용자 현재 위치 표시
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
                            .contentShape(Circle())
                            .onTapGesture {
                                viewModel.mapViewModel.updateUserLocationAndMoveCamera()
                            }
                            .padding(.top, 15)
                            .padding(.trailing, 15)
                    }
                } else {
                    // 혼잡도 데이터가 없는 경우 사용자 현재 위치 버튼만 표시
                    HStack(alignment: .top, spacing: 0) {
                        Spacer()
                        
                        // 사용자 현재 위치 표시
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
                            .contentShape(Circle())
                            .onTapGesture {
                                viewModel.mapViewModel.updateUserLocationAndMoveCamera()
                            }
                            .padding(.top, 15)
                            .padding(.trailing, 15)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    if viewModel.showRefreshButton {
                        // 재검색
                        HStack(spacing: 4) {
                            Text("현 지도 위치로 검색")
                                .font(.notosans(type: .medium, size: 13))
                            
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12)
                                .rotationEffect(.degrees(30))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color.accent.opacity(0.7))
                                .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.requestMapData()
                        }
                        .padding(.leading, 76)
                    }
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 3) {
                        Text("대피소")
                            .font(.notosans(type: .medium, size: 14))
                            .padding(.bottom, 1)
                        
                        Image(systemName: viewModel.mapViewModel.showShelters ? "checkmark.circle.fill" : "checkmark.circle")
                            .foregroundStyle(viewModel.mapViewModel.showShelters ? Color.accentColor : Color.dimC5D6Ca)
                            .onTapGesture {
                                viewModel.mapViewModel.toggleShelter()
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
                    )
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 15)
                
                if viewModel.showShelterInfo {
                    // 대피소 정보
                    ShelterMapInfoView(viewModel: viewModel.shelterInfoViewModel, show: $viewModel.showShelterInfo)
                } else if viewModel.showExitInfo {
                    // 비상구 정보
                    ExitMapInfoView(viewModel: viewModel.exitInfoViewModel)
                }
            }
            
            if viewModel.loading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.7)
                    .padding(25)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.accent.opacity(0.7))
                    )
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            NSLog("onAppear")
            let data = navigationViewModel.data as? Shelter
            self.viewModel.requestMapData(data)
            
            self.navigationViewModel.data = nil
        }
    }
}

#Preview {
    @State var show: Bool = true
    
    VStack {
        HStack(spacing: 3) {
            Text("대피소")
                .font(.notosans(type: .medium, size: 14))
                .padding(.bottom, 1)
            
            Image(systemName: show ? "checkmark.circle.fill" : "checkmark.circle")
//                .foregroundStyle(Color.accentColor)
                .foregroundStyle(show ? Color.accentColor : Color.dimC5D6Ca)
                .onTapGesture {
                    
                }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray)
                .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
        )
        
        Toggle(isOn: $show) {
            Text("대피소")
                .fixedSize()
        }
        .tint(.accent)
        
    }
}
