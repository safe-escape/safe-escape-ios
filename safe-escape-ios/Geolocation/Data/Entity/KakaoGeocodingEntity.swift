//
//  KakaoGeocodingEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/5/25.
//

import Foundation

// 카카오 로컬 API Geocoding Entity
struct KakaoGeocodingResponseEntity: ResponseEntity {
    let meta: KakaoGeocodingMetaEntity
    let documents: [KakaoGeocodingDocumentEntity]
    
    var success: Bool {
        return true
    }
    
    var data: (meta: KakaoGeocodingMetaEntity, address: [KakaoGeocodingDocumentEntity])? {
        return (meta, documents)
    }
}

struct KakaoGeocodingMetaEntity: Codable {
    let totalCount: Int
    let pageableCount: Int
    let isEnd: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case pageableCount = "pageable_count"
        case isEnd = "is_end"
    }
}

struct KakaoGeocodingDocumentEntity: Codable, Entity {
    let addressName: String
    let y: String
    let x: String
    let addressType: String
    let address: KakaoAddressEntity?
    let roadAddress: KakaoRoadAddressEntity?
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case y, x
        case addressType = "address_type"
        case address
        case roadAddress = "road_address"
    }
    
    func map() -> Address {
        var coordinate: Coordinate?
        if let x = Double(x), let y = Double(y) {
            coordinate = .init(latitude: y, longitude: x)
        }
        
        let roadAddr = roadAddress?.addressName ?? addressName
        let jibunAddr = address?.addressName ?? addressName
        
        return Address(road: roadAddr, jibun: jibunAddr, coordinate: coordinate)
    }
}

struct KakaoAddressEntity: Codable {
    let addressName: String
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let mountainYn: String
    let mainAddressNo: String
    let subAddressNo: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case mountainYn = "mountain_yn"
        case mainAddressNo = "main_address_no"
        case subAddressNo = "sub_address_no"
    }
}

struct KakaoRoadAddressEntity: Codable {
    let addressName: String
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let roadName: String
    let undergroundYn: String
    let mainBuildingNo: String
    let subBuildingNo: String
    let buildingName: String
    let zoneNo: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case roadName = "road_name"
        case undergroundYn = "underground_yn"
        case mainBuildingNo = "main_building_no"
        case subBuildingNo = "sub_building_no"
        case buildingName = "building_name"
        case zoneNo = "zone_no"
    }
}
