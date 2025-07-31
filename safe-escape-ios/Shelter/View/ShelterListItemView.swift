//
//  ShelterListItemView.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI
import SkeletonUI

struct ShelterListItemView: View {
    let shelter: Shelter?
    let isLoading: Bool
    let onTap: () -> Void
    
    private let appearance: AppearanceType = .solid(color: .accent.opacity(0.3),
                                                    background: .accent.opacity(0.1))
    
    var body: some View {
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
            .skeleton(with: isLoading,
                      size: CGSize(width: 30, height: 40),
                      animation: .pulse(),
                      appearance: appearance,
                      shape: .rounded(.radius(5)),
                      scales: [0: 0.8])
            .padding(.leading, isLoading ? 4 : 0)
            .padding(.top, isLoading ? 4 : 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shelter?.name ?? "")
                    .font(.notosans(type: .bold, size: 18))
                
                Text(shelter?.address ?? "")
                    .font(.notosans(type: .regular, size: 11))
                    .foregroundStyle(Color.font757575)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, -2)
            .skeleton(with: isLoading,
                      animation: .pulse(),
                      appearance: appearance,
                      lines: 2,
                      scales: [0: 0.7],
                      spacing: 11)
            .padding(.leading, isLoading ? -2 : 0)
            .padding(.top, isLoading ? 5 : 0)
            .padding(.bottom, isLoading ? 3 : 0)

            Text(DistanceFormatter.format(shelter?.distance ?? 0))
                .font(.notosans(type: .semibold, size: 15))
                .padding(.top, 1)
                .skeleton(with: isLoading,
                          size: CGSize(width: 40, height: 15),
                          animation: .pulse(),
                          appearance: appearance)
                .padding(.leading, isLoading ? 2 : 0)
                .padding(.top, isLoading ? 6 : 0)
        }
        .padding(.vertical, 24)
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.borderD9D9D9)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .padding(.top, 15)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    let shelter = Shelter(
        id: "1",
        name: "강남구 종합대피소",
        address: "서울시 강남구 테헤란로 123번길",
        coordinate: Coordinate(latitude: 37.5665, longitude: 126.9780),
        distance: 450.0,
        liked: false
    )
    
    return VStack(spacing: 0) {
        ShelterListItemView(shelter: shelter, isLoading: false) {
            print("Shelter tapped")
        }
        
        ShelterListItemView(shelter: nil, isLoading: true) {
            print("Loading shelter tapped")
        }
    }
    .padding(20)
}
