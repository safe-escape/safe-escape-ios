//
//  HomeRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation

class HomeRepository {
    static let shared = HomeRepository()
    
    private init() {}
    
    // TODO: API에서 데이터 받아오는 것으로 변경 필요 -> 현재는 Mock 데이터
    // 메인 데이터 조회
    func requestData(_ location: Coordinate) async throws -> SafetyMapData {
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
        
        // 실제 서울시 대피소 명칭과 유사한 Mock 데이터
        let shelterNames = [
            "강남구민회관 대피소", "서초구 종합운동장", "송파구 체육관", 
            "광진구 문화센터", "성동구 복합문화센터", "용산구 구민회관",
            "마포구 체육관", "서대문구 종합체육관", "은평구민회관",
            "노원구 문화예술회관", "도봉구 체육센터", "강북구민회관",
            "중랑구 복합문화센터", "동대문구 체육관", "성북구민회관"
        ]
        
        let roadNames = [
            "테헤란로", "강남대로", "서초대로", "송파대로", "광진로",
            "성동로", "용산로", "마포대로", "연세로", "은평로",
            "노원로", "도봉로", "강북로", "종로", "을지로"
        ]
        
        let districts = [
            "강남구", "서초구", "송파구", "광진구", "성동구",
            "용산구", "마포구", "서대문구", "은평구", "노원구",
            "도봉구", "강북구", "중랑구", "동대문구", "성북구"
        ]
        
        // 실제 서울시 동명
        let seoulDongs = [
            "강남동", "역삼동", "논현동", "압구정동", "청담동", "삼성동",
            "서초동", "반포동", "잠원동", "방배동", "양재동", "우면동",
            "송파동", "잠실동", "문정동", "가락동", "마천동", "풍납동",
            "광진동", "구의동", "자양동", "중곡동", "능동구역", "화양동",
            "성동동", "왕십리동", "마장동", "사근동", "행당동", "응봉동",
            "용산동", "이촌동", "한남동", "이태원동", "원효동", "청파동",
            "마포동", "공덕동", "아현동", "도화동", "용강동", "대흥동",
            "서대문동", "충정로동", "신촌동", "연희동", "홍제동", "홍은동",
            "은평동", "응암동", "역촌동", "갈현동", "구산동", "대조동"
        ]
        
        let shelters = (0..<10).map { _ in
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
                liked: Bool.random()
            )
            
            shelter.distance = LocationUsecase.shared.getDirectDistance(from: location, to: shelter.coordinate)
            
            return shelter
        }
        
        let crowded = (0..<3).map { _ in
            Crowded(coordinate: randomCoordinate(center: location, radiusInMeters: 2000), level: CrowdedLevel.allCases.randomElement() ?? .free)
        }
        
        // 좌표 기반 랜덤 폴리곤 생성
        func generatePolygonPoints(center: Coordinate, count: Int = 8, radius: Double = 0.005) -> [Coordinate] {
            // 1. 랜덤한 각도 배열 생성
            let angles = (0..<count).map { _ in Double.random(in: 0..<2 * .pi) }.sorted()

            // 2. 각도에 따라 점 생성 (원 형태로 퍼뜨리기)
            let points = angles.map { angle -> Coordinate in
                let r = radius * Double.random(in: 0.7...1.0) // 반지름 약간 랜덤하게
                let dx = r * cos(angle)
                let dy = r * sin(angle)

                return Coordinate(
                    latitude: center.latitude + dy,
                    longitude: center.longitude + dx
                )
            }

            return points
        }
        
        var exits: [Exit] = []
        let crowdedAreas = (0..<3).map { _ in
            let center = randomCoordinate(center: location, radiusInMeters: 1500)
            let crowdedArea = CrowdedArea(coordinates: generatePolygonPoints(center: center, count: Int.random(in: 5...8)))
            
            crowdedArea.coordinates.forEach {
                exits.append(Exit(coordinate: $0))
            }
            
            return crowdedArea
        }
        
        // 가장 혼잡한 지역 Mock 데이터 (랜덤 생성)
        // 33% 확률로 nil, 67% 확률로 데이터 생성
        let mostCrowdedArea: CrowdedNearBy?
        let randomValue = Int.random(in: 0...2)
        
        if randomValue == 0 {
            // 33% 확률: 데이터 없음 (nil)
            mostCrowdedArea = nil
        } else {
            // 67% 확률: 랜덤 데이터 생성
            let randomLevel = CrowdedLevel.allCases.randomElement() ?? .free
            let randomAddress = seoulDongs.randomElement() ?? "강남동"
            
            mostCrowdedArea = CrowdedNearBy(
                crowded: Crowded(
                    coordinate: randomCoordinate(center: location, radiusInMeters: 500),
                    level: randomLevel
                ),
                address: randomAddress
            )
        }
        
        return SafetyMapData(shelters: shelters, crowded: crowded, crowdedAreas: crowdedAreas, exits: exits, mostCrowdedArea: mostCrowdedArea)
    }
}
