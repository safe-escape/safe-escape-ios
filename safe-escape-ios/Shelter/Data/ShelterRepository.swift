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
    private var favoriteShelterIds: Set<String> = []
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 내 주변 대피소 조회
    func getNearbyShelters(_ location: Coordinate) async throws -> [Shelter] {
        // 해당 좌표로 부터 반경(m) 안의 랜덤 좌표 생성
        func randomCoordinate(
            center: Coordinate,
            radiusInMeters: Double
        ) -> Coordinate {
            // 무작위 각도 (0 ~ 2π)
            let theta = Double.random(in: 0..<2 * .pi)
            
            // 무작위 거리 (0 ~ radius), √로 보정해서 균일 분포 유지
            let distance = sqrt(Double.random(in: 0...1)) * radiusInMeters

            // 위도 변화 (1도 ≈ 111,000m)
            let deltaLat = distance * cos(theta) / 111_000.0

            // 경도 변화 (위도에 따른 보정 필요)
            let deltaLng = distance * sin(theta) / (111_000.0 * cos(center.latitude * .pi / 180))

            return Coordinate(
                latitude: center.latitude + deltaLat,
                longitude: center.longitude + deltaLng
            )
        }
        
        try await Task.sleep(for: .milliseconds(Int.random(in: 5...30) * 100))
        
        let range = Int.random(in: -3...15)
        guard range > 0 else {
            return []
        }
        
        // 실제 서울시 대피소 명칭과 유사한 Mock 데이터
        let shelterNames = [
            "강남구민회관 대피소", "서초구 종합운동장", "송파구 체육관", 
            "광진구 문화센터", "성동구 복합문화센터", "용산구 구민회관",
            "마포구 체육관", "서대문구 종합체육관", "은평구민회관",
            "노원구 문화예술회관", "도봉구 체육센터", "강북구민회관"
        ]
        
        let roadNames = [
            "테헤란로", "강남대로", "서초대로", "송파대로", "광진로",
            "성동로", "용산로", "마포대로", "연세로", "은평로",
            "노원로", "도봉로", "강북로", "종로", "을지로"
        ]
        
        let districts = [
            "강남구", "서초구", "송파구", "광진구", "성동구",
            "용산구", "마포구", "서대문구", "은평구", "노원구",
            "도봉구", "강북구", "종로구", "중구"
        ]
        
        return (0..<range).map { index in
            let shelterId = String(UUID().uuidString.prefix(8))
            let shelterName = shelterNames.randomElement() ?? "구민 대피소"
            let district = districts.randomElement() ?? "강남구"
            let roadName = roadNames.randomElement() ?? "테헤란로"
            let buildingNumber = Int.random(in: 1...300)
            let detailNumber = Int.random(in: 1...99)
            
            var shelter = Shelter(
                id: shelterId,
                name: shelterName,
                address: "서울시 \(district) \(roadName) \(buildingNumber)-\(detailNumber)",
                coordinate: randomCoordinate(center: location, radiusInMeters: 1500),
                liked: favoriteShelterIds.contains(shelterId)
            )
            
            shelter.distance = LocationUsecase.shared.getDirectDistance(from: location, to: shelter.coordinate)
            
            return shelter
        }
    }
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 찜한 대피소 목록 조회
    func getFavoriteShelters() async throws -> [Shelter] {
        try await Task.sleep(for: .milliseconds(Int.random(in: 3...15) * 100))
        
        // Mock 데이터: 찜한 대피소들 생성
        let size = Int.random(in: -2...8)
        guard size > 0 else {
            return []
        }
        
        // 찜한 대피소용 실제 서울시 대피소 명칭
        let favoriteShelterNames = [
            "서울시청 지하대피소", "광화문 종합상황실", "강남역 지하상가",
            "잠실종합운동장", "여의도 한강공원", "상암월드컵경기장",
            "올림픽공원 체조경기장", "동대문디자인플라자", "반포한강공원",
            "뚝섬한강공원", "청계천 문화관", "성수동 복합문화공간"
        ]
        
        let favoriteDistricts = [
            "중구", "종로구", "강남구", "송파구", "영등포구", "마포구",
            "강동구", "동대문구", "서초구", "성동구"
        ]
        
        let favoriteRoads = [
            "세종대로", "종로", "강남대로", "올림픽로", "여의대로", "월드컵로",
            "천호대로", "청계천로", "반포대로", "성수일로"
        ]
        
        let mockFavoriteShelters = Array(0..<size).map { index in
            let shelterId = "favorite_\(index)"
            favoriteShelterIds.insert(shelterId) // Mock에서 찜 상태 유지
            
            let shelterName = favoriteShelterNames.randomElement() ?? "시민 대피소"
            let district = favoriteDistricts.randomElement() ?? "중구"
            let roadName = favoriteRoads.randomElement() ?? "세종대로"
            let buildingNumber = Int.random(in: 1...500)
            
            return Shelter(
                id: shelterId,
                name: shelterName,
                address: "서울시 \(district) \(roadName) \(buildingNumber)",
                coordinate: Coordinate(
                    latitude: 37.5665 + Double.random(in: -0.05...0.05),
                    longitude: 126.9780 + Double.random(in: -0.05...0.05)
                ),
                distance: Double.random(in: 200...5000),
                liked: true
            )
        }
        
        return mockFavoriteShelters
    }
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 대피소 찜하기/찜 해제
    func toggleShelterFavorite(_ shelter: Shelter) async throws {
        try await Task.sleep(for: .milliseconds(Int.random(in: 2...8) * 100))
        
        if favoriteShelterIds.contains(shelter.id) {
            favoriteShelterIds.remove(shelter.id)
        } else {
            favoriteShelterIds.insert(shelter.id)
        }
    }
}
