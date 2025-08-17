//
//  ShelterRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/30/25.
//

import Foundation

class ShelterRepository {
    static let shared = ShelterRepository()
    
    private init() {}
    
    // Mock 찜한 대피소 ID 저장소 (실제로는 UserDefaults나 API 서버에 저장)
    private var favoriteShelterIds: Set<Int> = []
    
    // 내 주변 대피소 조회
    func getNearbyShelters(_ location: Coordinate) async throws -> [Shelter] {
        // 반경 2km의 좌표 계산
        let radiusInKm = 2.0
        let radiusInMeters = radiusInKm * 1000
        
        // 위도 1도 ≈ 111,000m
        let latDelta = radiusInMeters / 111_000.0
        
        // 경도 1도는 위도에 따라 변함 (위도가 높을수록 좁아짐)
        let lngDelta = radiusInMeters / (111_000.0 * cos(location.latitude * .pi / 180))
        
        // 남서쪽 좌표 (latitude 감소, longitude 감소)
        let southWest = Coordinate(
            latitude: location.latitude - latDelta,
            longitude: location.longitude - lngDelta
        )
        
        // 북동쪽 좌표 (latitude 증가, longitude 증가)
        let northEast = Coordinate(
            latitude: location.latitude + latDelta,
            longitude: location.longitude + lngDelta
        )
        
        let bounds = MapBounds(southWest: southWest, northEast: northEast)
        let safetyMapData = try await HomeDataSource.shared.getData(bounds: bounds).map()
        return safetyMapData.shelters
    }
    
    // 찜한 대피소 목록 조회
    func getFavoriteShelters() async throws -> [Shelter] {
        let dataEntities = try await ShelterDataSource.shared.getBookmarkedShelters()
        return dataEntities.map { $0.map() }
    }
    
    // 대피소 찜하기/찜 해제
    func toggleShelterFavorite(_ shelter: Shelter) async throws -> Shelter {
        if shelter.liked {
            // 이미 찜한 상태 -> 찜 해제 (DELETE)
            _ = try await ShelterDataSource.shared.removeBookmark(shelterId: shelter.id)
            var updatedShelter = shelter
            updatedShelter.liked = false
            return updatedShelter
        } else {
            // 찜하지 않은 상태 -> 찜하기 (POST)
            let dataEntity = try await ShelterDataSource.shared.addBookmark(shelterId: shelter.id)
            return dataEntity.map()
        }
    }
}
