//
//  InputAddressView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import SwiftUI

// 주소 검색 뷰
struct InputAddressView: View {
    @ObservedObject var viewModel: InputAddressViewModel
    var type: InputAddressViewType = .shadow
    var radius: CGFloat = 15
    var height: CGFloat = 56
    
    @FocusState var inputAddressFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // 주소 검색 Input
            TextField("주소 검색", text: $viewModel.textInputAddress)
            .focused($inputAddressFocused)
            .font(.notosans(type: .medium, size: 16))
            .keyboardType(.default)
            .onSubmit {
                // 엔터키 눌렀을 때 검색 실행
                inputAddressFocused = false
                
                guard !viewModel.showOverlay else {
                    viewModel.showOverlay = false
                    return
                }
                
                viewModel.findAddress()
            }
            .onChange(of: inputAddressFocused) { focused in
                guard focused, viewModel.errorState == nil else {
                    return
                }
                
                // Input 포커스 된 경우, 주소 리스트 닫기
                viewModel.showOverlay = false
            }
            .onChange(of: viewModel.errorState) { state in
                guard state != nil else {
                    return
                }
                
                // 에러 있는 경우, 다시 입력하도록 포커스 처리
                inputAddressFocused = true
                
                // 1.5초 후 에러 문구 닫도록 처리
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.viewModel.showOverlay = false
                    self.viewModel.errorState = nil
                }
            }
            .onChange(of: viewModel.focusRequest) { req in
                guard req != .none else {
                    return
                }
                
                // 포커스 요청에 따라 포커싱 처리
                inputAddressFocused = req == .focusIn
                viewModel.focusRequest = .none
            }
            .onChange(of: viewModel.focusRequest) { req in
                guard req != .none else {
                    return
                }
                
                // 포커스 요청에 따라 포커싱 처리
                inputAddressFocused = req == .focusIn
                viewModel.focusRequest = .none
            }
            
            Spacer(minLength: 0)
            
            if viewModel.loading {
                // 로딩
                ProgressView()
                    .tint(.accent)
                    .frame(width: 40)
                    
            } else {
                // 검색
                Image(.magnifier)
                    .onTapGesture {
                        inputAddressFocused = false
                        
                        guard !viewModel.showOverlay else {
                            viewModel.showOverlay = false
                            return
                        }
                        
                        viewModel.findAddress()
                    }
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 8)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: radius)
                .fill(.white)
                .shadow(color: .black.opacity(type == .shadow ? 0.16 : 0), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(.borderD7D7D7, lineWidth: 1)
                .opacity(type == .border ? 1 : 0)
        )
        .overlay(alignment: .top) {
            // 주소 리스트 / 에러 문구
            VStack(spacing: 6) {
                Spacer(minLength: height)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // 에러 있는 경우, 에러 문구 표시
                        if let errorState = viewModel.errorState {
                            VStack {
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24)
                                    .foregroundStyle(Color.gray)
                                
                                Text(errorState == .validateFailed ? "주소는 두 글자 이상 입력해주세요" : "해당하는 주소가 없습니다\n주소를 다시 입력해주세요")
                                    .font(.notosans(type: .medium, size: 15))
                                    .foregroundStyle(Color.gray)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 10)
                        } else { // 그 외, 주소 리스트 노출
                            ForEach(Array(viewModel.addressList.enumerated()), id: \.element.road) { index, address in
                                VStack(spacing: 4) {
                                    HStack {
                                        Text("도로명")
                                            .font(.notosans(type: .regular, size: 10))
                                            .foregroundStyle(Color.accentColor)
                                            .frame(width: 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .fill(Color.accentColor.opacity(0.1))
                                            )
                                        
                                        Text(address.road)
                                            .font(.notosans(type: .medium, size: 13))
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    
                                    // 지번 주소 있는 경우에만 노출
                                    if let jibun = address.jibun, !jibun.isEmpty {
                                        HStack {
                                            Text("지번")
                                                .font(.notosans(type: .regular, size: 10))
                                                .foregroundStyle(Color.init(hex: "#ffaa00")!)
                                                .frame(width: 40)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .fill(Color.yellow.opacity(0.15))
                                                )
                                            
                                            Text(jibun)
                                                .font(.notosans(type: .regular, size: 11.5))
                                                .foregroundStyle(Color.font898989)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer(minLength: 0)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .padding(.top, -2)
                                .background(Color.white)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectAddress(address)
                                }
                                .onAppear {
                                    // 마지막에서 3번째 아이템이 나타나면 더 로드
                                    if index == viewModel.addressList.count - 3 {
                                        viewModel.loadMoreAddress()
                                    }
                                }
                            }
                            
                            // 추가 로딩 인디케이터
                            if viewModel.isLoadingMore {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .tint(.accent)
                                        .scaleEffect(0.8)
                                    Text("더 많은 주소를 불러오는 중...")
                                        .font(.notosans(type: .regular, size: 12))
                                        .foregroundStyle(Color.gray)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 2)
                )
                .frame(maxHeight: viewModel.showOverlay ? maxHeight * 0.3 : 0)
                .animation(.interpolatingSpring(mass: 0.1, stiffness: 170, damping: 10), value: viewModel.showOverlay)
            }
            .fixedSize(horizontal: false, vertical: true)
            .opacity(viewModel.showOverlay ? 1 : 0)
            .animation(.easeIn(duration: 0.1), value: viewModel.showOverlay)
        }
        .zIndex(10)
    }
}
