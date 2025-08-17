//
//  CrowdedNearByEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation

// 혼잡 지역 주변 조회 요청 파라미터
struct CrowdedNearByRequest: Codable {
    let latitude: Double
    let longitude: Double
    let size: Int = 5 // 하드코딩된 기본값
}

// 혼잡 지역 주변 조회 API 응답 Entity
struct CrowdedNearByResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: [CrowdedNearByDataEntity]?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 혼잡 지역 주변 데이터 Entity
struct CrowdedNearByDataEntity: Entity {
    let latitude: Double
    let longitude: Double
    let name: String
    let level: String
    
    typealias Model = CrowdedNearBy
    
    func map() -> CrowdedNearBy {
        return CrowdedNearBy(
            crowded: Crowded(
                coordinate: Coordinate(latitude: latitude, longitude: longitude),
                level: CrowdedLevel(rawValue: level) ?? .normal
            ),
            address: name
        )
    }
}

// 혼잡도 예상 조회 요청 Entity
struct CrowdedPredictionRequest: Codable {
    let date: String
    let hour: Int
    let locations: [Int]?
    
    init(date: Date, locations: [Int]? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        self.date = formatter.string(from: date)
        
        let calendar = Calendar.current
        self.hour = calendar.component(.hour, from: date)
        self.locations = locations
    }
}

// 혼잡도 예상 조회 API 응답 Entity
struct CrowdedPredictionResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: CrowdedPredictionDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 혼잡도 예상 데이터 Entity
struct CrowdedPredictionDataEntity: Entity {
    let date: String
    let hour: Int
    let weekday: Int
    let holiday: Int
    let n_locations: Int
    let predictions: [CrowdedLocationPredictionEntity]
    
    typealias Model = CrowdedLevel
    
    func map() -> CrowdedLevel {
        // 첫 번째 예측 결과의 혼잡도 레벨을 반환 (기존 API 호환성을 위해)
        if let firstPrediction = predictions.first {
            return CrowdedLevel.allCases[safe: firstPrediction.congestion_level] ?? .normal
        }
        return .normal
    }
}

// 개별 위치 예상 Entity
struct CrowdedLocationPredictionEntity: Codable {
    let location: Int
    let congestion_level: Int
    let proba: [String: Double]
}

// Array extension for safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
