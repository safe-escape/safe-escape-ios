//
//  ShelterRowView.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI

struct ShelterRowView: View {
    let shelter: Shelter
    let onHeartTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(shelter.name)
                    .font(.notosans(type: .semibold, size: 16))
                    .foregroundStyle(Color.font1E1E1E)
                
                Text(shelter.address)
                    .font(.notosans(type: .regular, size: 14))
                    .foregroundStyle(Color.font757575)
                    .lineLimit(2)
                
                if let distance = shelter.distance {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.font898989)
                        
                        Text(String(format: "%.0fm", distance))
                            .font(.notosans(type: .regular, size: 12))
                            .foregroundStyle(Color.font898989)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onHeartTap) {
                Image(systemName: shelter.liked ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundStyle(shelter.liked ? Color.pointRed : Color.font898989)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    let shelter = Shelter(
        id: 1,
        name: "찜한대피소_1",
        address: "서울시 강남구 테헤란로 123번길",
        coordinate: Coordinate(latitude: 37.5665, longitude: 126.9780),
        distance: 450.0,
        liked: true
    )
    
    return ShelterRowView(shelter: shelter) {
        print("Heart tapped")
    }
    .padding(20)
}
