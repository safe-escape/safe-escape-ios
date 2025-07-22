//
//  HomeView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI
import NMapsMap

struct NaverMapView: UIViewRepresentable {
    @ObservedObject var viewModel: HomeViewModel
    
    private let shelterMarkerImage = NMFOverlayImage(name: "shelter_marker")
    private let shelterMarkerSelectedImage = NMFOverlayImage(name: "shelter_marker_selected")
    
    private let exitMarkerImage = NMFOverlayImage(name: "exit_marker")
    private let exitMarkerSelectedImage = NMFOverlayImage(name: "exit_marker_selected")
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        
        mapView.latitude = 37.5630529
        mapView.longitude = 126.9702998
        
        mapView.locationOverlay.icon = NMFOverlayImage(name: "current_user_location_overlay")
        mapView.locationOverlay.location = NMGLatLng(lat: 37.5606529, lng: 126.9732998)
        
        let marker = NMFMarker(position: NMGLatLng(lat: 37.5630530, lng: 126.97028), iconImage: shelterMarkerImage)
        marker.width = 48
        marker.height = 48
        marker.touchHandler = { overlay in
            if let marker = overlay as? NMFMarker {
                if marker.iconImage == shelterMarkerImage {
                    marker.iconImage = shelterMarkerSelectedImage
                    viewModel.showShelterInfo = true
                } else {
                    marker.iconImage = shelterMarkerImage
                    viewModel.showShelterInfo = false
                }
            }
            return true
        }
        marker.position = NMGLatLng(lat: 37.5630529, lng: 126.9702998)
        marker.mapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        mapView.locationOverlay.hidden = !viewModel.showCurrentUserLocation
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
    
    @FocusState var inputAddressFocused: Bool
    
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            // TODO: 네이버 지도
            NaverMapView(viewModel: viewModel)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TextField("주소 검색", text: $viewModel.textInputAddress) {
                        
                    }
                    .focused($inputAddressFocused)
                    .font(.notosans(type: .medium, size: 16))
                    .keyboardType(.default)
                    
                    Spacer(minLength: 0)
                    
                    Image(.magnifier)
                        .onTapGesture {
                            // TODO: 검색
                            inputAddressFocused = false
                        }
                }
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 2)
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
                        .onTapGesture {
                            viewModel.showCurrentUserLocation.toggle()
                        }
                        .padding(.top, 15)
                        .padding(.trailing, 15)
                    
                }
                
                Spacer()
                
                if viewModel.showShelterInfo {
                    ShelterInfoView(info: viewModel.shelterInfo!, show: $viewModel.showShelterInfo)
//                        .transition(.offset(y: 10).combined(with: .opacity))
                        .transition(.opacity.animation(.easeInOut).combined(with: .offset(y: 10)))
                }
                
                if viewModel.showExitInfo {
                    
                }
            }
        }
        .onAppear {
            NSLog("onAppear")
        }
    }
}

// 대피소 정보
struct ShelterInfoView: View {
    var info: ShelterInfo
    
    @Binding var show: Bool
    
    var body: some View {
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
                    Text(info.name)
                        .font(.notosans(type: .semibold, size: 20))
                    
                    Image(systemName: info.liked ? "heard.fill" : "heart")
                        .foregroundStyle(info.liked ? Color.pointRed : Color.black)
                        .padding(.bottom, 4)
                }
                
                Text(info.address)
                    .font(.notosans(type: .regular, size: 10))
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                
                Button {
                    // TODO: 현재 위치에서 길찾기
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

// 혼잡지역 - 비상구 추천
struct ExitInfoView: View {
    
    var body: some View {
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

//#Preview {
//    HomeView()
//}
