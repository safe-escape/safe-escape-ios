//
//  CrowdedNearByListView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import SwiftUI
import SkeletonUI

// 내 주변 혼잡한 지역 뷰
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
            
            // No data인 경우
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
            } else { // 그 외, 로딩 중이면 Skeleton UI로 로딩 화면(2개) / 데이터 있으면 전체 데이터 리스트 표시
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
                            .padding(.top, viewModel.nearByLoading ? -2 : 6)
                        
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
                                .padding(.bottom, viewModel.nearByLoading ? 10 : 4)
                        }
                        .padding(.top, viewModel.nearByLoading ? -8 : -2)
                        
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
    CrowdedNearByListView(viewModel: .init())
}
