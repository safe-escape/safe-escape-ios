//
//  ShelterUsecase.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/30/25.
//

import Foundation

class ShelterUsecase {
    static let shared = ShelterUsecase()
    
    private init() {}
    
    func getNearByShelterList() async throws -> [Shelter] {
        let location = try await LocationUsecase.shared.getCurrentLocation()
        
        return try await ShelterRepository.shared.getNearbyShelters(location)
            .map { shelter in
                var shelter = shelter
                shelter.distance = LocationUsecase.shared.getDirectDistance(from: location, to: shelter.coordinate)
                return shelter
            }
            .sorted(by: { $0.distance <= $1.distance })
    }
    
    // 즐겨찾기 대피소 조회
    func getFavoriteShelters() async throws -> [Shelter] {
        let location = try await LocationUsecase.shared.getCurrentLocation()
        return try await ShelterRepository.shared.getFavoriteShelters().map {
            var shelter = $0
            shelter.distance = LocationUsecase.shared.getDirectDistance(from: location, to: $0.coordinate)
            return shelter
        }.sorted(by: { $0.distance <= $1.distance })
    }
    
    // 대피소 찜하기/찜 해제 토글
    func toggleShelterFavorite(_ shelter: Shelter) async throws -> Shelter {
        return try await ShelterRepository.shared.toggleShelterFavorite(shelter)
    }
}
