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
    }
    
    func getFavoriteShelters() async throws -> [Shelter] {
        return try await ShelterRepository.shared.getFavoriteShelters()
    }
    
    func toggleShelterFavorite(_ shelter: Shelter) async throws {
        try await ShelterRepository.shared.toggleShelterFavorite(shelter)
    }
}
