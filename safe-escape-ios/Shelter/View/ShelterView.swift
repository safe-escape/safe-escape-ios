//
//  ShelterView.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import SwiftUI
import SkeletonUI

struct ShelterView: View {
    @StateObject var viewModel = ShelterViewModel()
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    private let appearance: AppearanceType = .solid(color: .accent.opacity(0.3),
                                                    background: .accent.opacity(0.1))
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("내 주변 대피소")
                        .font(.notosans(type: .bold, size: 20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                    
                    if !viewModel.loading, viewModel.shelters.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                            
                            Text("주변에 대피소가 없습니다")
                                .font(.notosans(type: .medium, size: 16))
                        }
                        .padding(.bottom, 5)
                        .foregroundStyle(Color.accent.opacity(0.7))
                        .frame(maxWidth: .infinity, minHeight: 220)
                        
                        Spacer()
                    } else {
                        VStack {
                            Text("주변에 총 ")
                            + Text("\(viewModel.shelters.count)개")
                                .font(.notosans(type: .bold, size: 15))
                                .foregroundColor(Color.pointRed)
                            + Text("의 대피소가 있어요 !")
                        }
                        .skeleton(with: viewModel.loading,
                                  size: CGSize(width: UIScreen.main.bounds.width * 0.6, height: 12),
                                  animation: .pulse(),
                                  appearance: appearance)
                        .padding(.top, viewModel.loading ? 7 : 0)
                        .padding(.bottom, viewModel.loading ? 3 : 0)
                            
                        SkeletonForEach(with: viewModel.shelters, quantity: viewModel.loading ? 5 : viewModel.shelters.count) { _, shelter in
                            HStack(alignment: .top) {
                                VStack(spacing: 2) {
                                    Image(.shelterMarker)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 34)
                                    
                                    Circle()
                                        .frame(width: 7)
                                        .foregroundStyle(Color.pointRed)
                                }
                                .skeleton(with: viewModel.loading,
                                          size: CGSize(width: 30, height: 40),
                                          animation: .pulse(),
                                          appearance: appearance,
                                          shape: .rounded(.radius(5)),
                                          scales: [0: 0.8])
                                .padding(.leading, viewModel.loading ? 4 : 0)
                                .padding(.top, viewModel.loading ? 4 : 0)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(shelter?.name)
                                        .font(.notosans(type: .bold, size: 18))
                                    
                                    Text(shelter?.address)
                                        .font(.notosans(type: .regular, size: 11))
                                        .foregroundStyle(Color.font757575)
                                }
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, -2)
                                .skeleton(with: viewModel.loading,
                                          animation: .pulse(),
                                          appearance: appearance,
                                          lines: 2,
                                          scales: [0: 0.7],
                                          spacing: 11)
                                .padding(.leading, viewModel.loading ? -2 : 0)
                                .padding(.top, viewModel.loading ? 5 : 0)
                                .padding(.bottom, viewModel.loading ? 3 : 0)

                                Text(DistanceFormatter.format(shelter?.distance ?? 0))
                                    .font(.notosans(type: .semibold, size: 15))
                                    .padding(.top, 1)
                                    .skeleton(with: viewModel.loading,
                                              size: CGSize(width: 40, height: 15),
                                              animation: .pulse(),
                                              appearance: appearance)
                                    .padding(.leading, viewModel.loading ? 2 : 0)
                                    .padding(.top, viewModel.loading ? 6 : 0)
                            }
                            .padding(.vertical, 24)
                            .padding(.leading, 10)
                            .padding(.trailing, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.borderD9D9D9)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard let shelter else {
                                    return
                                }
                                navigationViewModel.navigate(.home, shelter)
                            }
                            .padding(.top, 15)
                        }
                    }
                    
                    Spacer(minLength: 5)
                }
                .font(.notosans(type: .regular, size: 15))
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.white)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.backgroundF7F7F7)
        .onAppear {
            viewModel.requestData()
        }
    }
}

#Preview {
    ShelterView()
}
