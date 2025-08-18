//
//  NaverGeocodingEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/22/25.
//

import Foundation

// 네이버 Maps Geocoding Entity
struct NaverGeocodingResponseEntity: ResponseEntity {
    let status: String
    let meta: NaverGeocodingMetaEntity
    let addresses: [NaverGeocodingAddressEntity]
    let errorMessage: String?
    
    var success: Bool {
        return status == "200" || status.contains("OK")
    }
    
    var data: (meta: NaverGeocodingMetaEntity, address: [NaverGeocodingAddressEntity])? {
        return (meta, addresses)
    }
}

struct NaverGeocodingMetaEntity: Codable {
    let totalCount: Int
    let page: Int?
    let count: Int
}

struct NaverGeocodingAddressEntity: Codable, Entity {
    let roadAddress: String
    let jibunAddress: String
    let englishAddress: String
    let x: String
    let y: String
    
    func map() -> Address {
        var coordinate: Coordinate?
        if let x = Double(x), let y = Double(y) {
            coordinate = .init(latitude: y, longitude: x)
        }
        
        return Address(road: roadAddress, jibun: jibunAddress, coordinate: coordinate)
    }
}
