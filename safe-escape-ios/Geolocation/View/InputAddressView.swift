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
            TextField("주소 검색", text: $viewModel.textInputAddress) {
                
            }
            .focused($inputAddressFocused)
            .font(.notosans(type: .medium, size: 16))
            .keyboardType(.default)
            .onChange(of: inputAddressFocused) { focused in
                guard focused else {
                    return
                }
                
                // Input 포커스 된 경우, 주소 리스트 닫기
                viewModel.showAddressList = false
            }
            .onChange(of: viewModel.errorState) { state in
                guard let state else {
                    return
                }
                
                // 에러 있는 경우, 다시 입력하도록 포커스 처리
                inputAddressFocused = true
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
                        
                        guard !viewModel.showAddressList else {
                            viewModel.showAddressList = false
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
            // 주소 리스트
            VStack(spacing: 6) {
                Spacer(minLength: height)
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.addressList, id: \.road) { address in
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
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 2)
                )
                .frame(maxHeight: viewModel.showAddressList ? maxHeight * 0.3 : 0)
                .animation(.interpolatingSpring(mass: 0.1, stiffness: 170, damping: 10), value: viewModel.showAddressList)
            }
            .fixedSize(horizontal: false, vertical: true)
            .opacity(viewModel.showAddressList ? 1 : 0)
            .animation(.easeIn(duration: 0.1), value: viewModel.showAddressList)
        }
        .zIndex(10)
    }
}
