//
//  CrowdedExpectView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import SwiftUI
import SkeletonUI

// 혼잡도 예상 뷰
struct CrowdedExpectView: View {
    @ObservedObject var viewModel: CrowdedViewModel
    @EnvironmentObject var keyboardManager: KeyboardManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("👥  혼잡도 예상")
                .font(.notosans(type: .bold, size: 20))
            
            Text("원하는 날짜, 위치의 혼잡도를 예상해드려요")
                .font(.notosans(type: .regular, size: 15))
                .padding(.top, -2)
            
            // 주소 검색
            InputAddressView(viewModel: viewModel.inputAddressViewModel, type: .border, radius: 10, height: 40)
                .disabled(viewModel.expectLoading)
                .zIndex(10)
            
            // 날짜 검색
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
                    // Date Picker
                    DatePicker("", selection: $viewModel.selectedExpectedDate, in: viewModel.minDate...viewModel.maxDate, displayedComponents: .date)
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
            .onChange(of: keyboardManager.showKeyboard) { show in
                guard show else {
                    return
                }
                
                // 키보드 올라온 경우, 주소 검색에 focus 되어있으므로 date picker 닫기
                viewModel.showDatePicker = false
            }
            
            // 혼잡도 예상 버튼
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
                        .fill(viewModel.enableExpectButton ? .accent : .dimC5D6Ca)
                )
            }
            .buttonStyle(CommonStateButtonStyle())
            .padding(.top, 2)
            .disabled(viewModel.expectLoading || !viewModel.enableExpectButton) // enable 처리
            
            // 혼잡도 예상 결과 뷰
            VStack {
                // 혼잡도 예상 결과가 있는 경우, 주소 / 날짜 / 혼잡도 표시
                if let crowded = viewModel.expectedCrowded, let crowdedLevel = viewModel.expectedCrowdedLevel {
                    // 주소
                    Text(crowded.address)
                        .font(.notosans(type: .bold, size: 15))
                    + Text(TopicFormatter.getTopicMarker(crowded.address) + "\n")
                    // 날짜
                    + Text(crowded.date.format() + "일")
                        .font(.notosans(type: .bold, size: 15))
                    + Text("에\n")
                    // 혼잡도
                    + Text(viewModel.getCrowdedLevelText(crowdedLevel))
                        .font(.notosans(type: .bold, size: 15))
                        .foregroundColor(viewModel.getCrowdedLevelColor(crowdedLevel))
                    + Text("\(viewModel.getCrowdedLevelTextMarker(crowdedLevel)) 예정입니다")
                        .font(.notosans(type: .regular, size: 15))
                } else if !viewModel.expectLoading, let defaultExpectedText = viewModel.defaultExpectedText { // 그 외, 로딩 중이 아니면 default text 노출
                    defaultExpectedText.enumerated().reduce(Text("")) { result, pair in
                        let (index, word) = pair
                        return result + Text(word)
                            .font(.notosans(type: index == 1 ? .bold : .regular, size: 15))
                    }
                }
            }
            // 로딩 시, Skeleton UI로 로딩 화면 표시
            .skeleton(with: viewModel.expectLoading || viewModel.defaultExpectedText == nil,
                      animation: .pulse(),
                      appearance: .solid(color: .accent.opacity(0.3),
                                         background: .accent.opacity(0.1)),
                      lines: 3,
                      scales: [0: 0.5, 1: 0.6, 2: 0.95],
                      spacing: 12)
            .padding(.horizontal, 5)
            .padding(.vertical, viewModel.hasExpectedCrowded ? 5 : 10)
            .font(.notosans(type: .regular, size: 15))
            .lineSpacing(2)
            .multilineTextAlignment(viewModel.hasExpectedCrowded ? .leading : .center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: viewModel.hasExpectedCrowded ? .leading : .center)
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


#Preview {
    CrowdedExpectView(viewModel: .init())
        .environmentObject(KeyboardManager())
}
