//
//  ShelterBookmarkEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation

// 즐겨찾기 대피소 조회 API 응답 Entity
struct ShelterBookmarkResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: [ShelterBookmarkDataEntity]?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 즐겨찾기 대피소 데이터 Entity
struct ShelterBookmarkDataEntity: Entity {
    let id: Int
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    
    typealias Model = Shelter
    
    func map() -> Shelter {
        return Shelter(
            id: id,
            name: name,
            address: address,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            distance: nil,
            liked: true // 즐겨찾기 조회이므로 항상 true
        )
    }
}

// 대피소 찜하기 API 응답 Entity (POST - 찜하기)
struct ShelterBookmarkAddResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: ShelterBookmarkDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 대피소 찜 해제 API 응답 Entity (DELETE - 찜 해제)
struct ShelterBookmarkRemoveResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: String? // 찜 해제 시 null로 내려옴
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}