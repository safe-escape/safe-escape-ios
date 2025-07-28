//
//  CrowdedView.swift
//  safe-escape-ios
//
//  Created by Cindy on 7/27/25.
//

import SwiftUI
import SkeletonUI

struct CrowdedView: View {
    @StateObject var viewModel: CrowdedViewModel = CrowdedViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                VStack(spacing: 20) {
                    CrowdedExpectView(viewModel: viewModel)
                        .zIndex(2)
                    
                    CrowdedNearByListView(viewModel: viewModel)
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .background(Color.backgroundF7F7F7)
        .onAppear {
            viewModel.requestData()
        }
    }
}

struct CrowdedExpectView: View {
    @ObservedObject var viewModel: CrowdedViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("👥 혼잡도 예상")
                .font(.notosans(type: .bold, size: 20))
            
            Text("원하는 날짜, 위치의 혼잡도를 예상해드려요")
                .font(.notosans(type: .regular, size: 15))
                .padding(.top, -2)
            
            InputAddressView(viewModel: viewModel.inputAddressViewModel, type: .border, radius: 10, height: 40)
                .disabled(viewModel.expectLoading)
                .zIndex(10)
            
            HStack {
                Text("\(viewModel.expectedDate)")
                    .font(.notosans(type: .medium, size: 16))
                    .foregroundStyle(viewModel.expectedDate == "날짜" ? Color(.placeholderText) : Color.black)
                    
                Spacer()
            }
            .padding(.leading, 20)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.borderD7D7D7, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.inputAddressViewModel.focusRequest = .focusOut
                viewModel.showDatePicker.toggle()
            }
            .overlay(alignment: .top) {
                VStack {
                    DatePicker("", selection: $viewModel.selectedExpectedDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .labelsHidden()
                        .scaleEffect(0.95)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Text("확인")
                            .font(.notosans(type: .medium, size: 15))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }
                    .frame(height: 46)
                    .background(Color.accent)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.changeDate()
                    }
                    .padding(.top, -5)
                }
                .padding(.top, -10)
                .cornerRadius(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
                )
                .padding(.top, 40 + 8)
                .opacity(viewModel.showDatePicker ? 1 : 0)
            }
            .zIndex(2)
            .disabled(viewModel.expectLoading)
            
            Button {
                viewModel.expectCrowded()
            } label: {
                HStack {
                    Spacer()
                    
                    Text("혼잡도 예상하기")
                        .font(.notosans(type: .bold, size: 15))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                }
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.enableExpectButton ? .accent : Color(.placeholderText))
                )
            }
            .buttonStyle(CommonStateButtonStyle())
            .padding(.top, 2)
            .disabled(viewModel.expectLoading || !viewModel.enableExpectButton)
            
            VStack {
                if !viewModel.expectLoading, let defaultExpectedText = viewModel.defaultExpectedText {
                    defaultExpectedText.enumerated().reduce(Text("")) { result, pair in
                        let (index, word) = pair
                        return result + Text(word)
                            .font(.notosans(type: index == 1 ? .bold : .regular, size: 15))
                            
                    }
                    
                } else if let crowded = viewModel.expectedCrowded {
                    Text(viewModel.inputAddressViewModel.textInputAddress)                     .font(.notosans(type: .bold, size: 15))
                    + Text(TopicFormatter.appendTopicMarker(viewModel.inputAddressViewModel.textInputAddress) + "\n")
                    + Text(viewModel.selectedExpectedDate.format())
                        .font(.notosans(type: .bold, size: 15))
                    + Text("에\n")
                    + Text(viewModel.getCrowdedLevelText(crowded))
                        .font(.notosans(type: .bold, size: 15))
                        .foregroundColor(viewModel.getCrowdedLevelColor(crowded))
                    + Text("\(viewModel.getCrowdedLevelTextMarker(crowded)) 예정입니다")
                        .font(.notosans(type: .regular, size: 15))
                }
            }
            .skeleton(with: viewModel.expectLoading || viewModel.defaultExpectedText == nil,
                      animation: .pulse(),
                      appearance: .solid(color: .accent.opacity(0.3), background: .accent.opacity(0.1)),
                      lines: 3,
                      scales: [0: 0.5, 1: 0.6, 2: 0.95],
                      spacing: 12)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
            .font(.notosans(type: .regular, size: 15))
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 100)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.backgroundF4F4F4)
            )
            .padding(.vertical, 5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(Color.white)
        )
        .padding(.horizontal, 20)
    }
}

struct CrowdedNearByListView: View {
    @ObservedObject var viewModel: CrowdedViewModel
    
    private let appearance: AppearanceType = .solid(color: .accent.opacity(0.3), background: .accent.opacity(0.1))
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📍 내 주변 가장 혼잡한 지역")
                .font(.notosans(type: .bold, size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("혼잡한 지역은 어딜까?")
                .font(.notosans(type: .regular, size: 15))
                .padding(.top, -2)
                .padding(.bottom, 6)
            
            if !viewModel.nearByLoading, viewModel.nearByList.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                    
                    Text("주변에 혼잡한 지역이 없습니다")
                        .font(.notosans(type: .medium, size: 16))
                }
                .padding(.bottom, 5)
                .foregroundStyle(Color.accent.opacity(0.7))
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.backgroundF4F4F4)
                )
                .padding(.bottom, 5)
            } else {
                SkeletonForEach(with: viewModel.nearByList, quantity: viewModel.nearByLoading ? 2 : viewModel.nearByList.count) { _, data in
                    HStack(alignment: .top, spacing: 5) {
                        Image(.crowdedTabSelected)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 17)
                            .skeleton(with: viewModel.nearByLoading,
                                      size: CGSize(width: 20, height: 20),
                                      animation: .pulse(),
                                      appearance: appearance,
                                      shape: .rounded(.radius(8)))
                            .padding(.top, viewModel.nearByLoading ? -2 : 0)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data?.address)
                                .font(.notosans(type: .bold, size: 18))
                                .skeleton(with: viewModel.nearByLoading,
                                          animation: .pulse(),
                                          appearance: appearance,
                                          scales: [0: 0.5])
                                .padding(.top, viewModel.nearByLoading ? 6 : 2)
                                .padding(.bottom, viewModel.nearByLoading ? 4 : 0)
                            
                            Text(viewModel.getCrowdedLevelText(data))
                                .font(.notosans(type: .regular, size: 15))
                                .skeleton(with: viewModel.nearByLoading,
                                          animation: .pulse(),
                                          appearance: appearance,
                                          scales: [0: 0.9])
                                .padding(.top, 2)
                                .padding(.bottom, 10)
                        }
                        .padding(.top, -8)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(viewModel.nearByLoading ? .vertical : .bottom, viewModel.nearByLoading ? 6 : 10)
                    .frame(minHeight: 68)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(Color.borderEdeded)
                            .padding(.horizontal, 4)
                        , alignment: .bottom)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(Color.white)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    CrowdedView()
}
