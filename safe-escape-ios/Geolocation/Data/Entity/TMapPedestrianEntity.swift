//
//  TMapPedestrianEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation
import CoreLocation

// SK Open API - TMAP 보행자 도로 검색 Entity
struct TMapPedestrianEntity: ResponseEntity {
    let type: String
    let features: [TMapFeatureEntity]
    
    var success: Bool {
        return true
    }
    
    var data: [TMapFeatureEntity]? {
        return features
    }
}

// MARK: - Feature
struct TMapFeatureEntity: Codable {
    let type: String
    let geometry: TMapGeometryEntity
    let properties: TMapFeaturePropertiesEntity
}

// MARK: - Geometry
struct TMapGeometryEntity: Codable, Entity {
    let type: GeometryType
    let coordinates: Coordinates

    enum GeometryType: String, Codable {
        case point = "Point"
        case lineString = "LineString"
    }

    enum Coordinates: Codable {
        case point([Double])
        case lineString([[Double]])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let point = try? container.decode([Double].self) {
                self = .point(point)
            } else if let lineString = try? container.decode([[Double]].self) {
                self = .lineString(lineString)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid coordinate format")
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .point(let coords):
                try container.encode(coords)
            case .lineString(let coords):
                try container.encode(coords)
            }
        }
    }
    
    func map() -> [Coordinate]? {
        switch coordinates {
        case .point(let array):
            guard array.count == 2 else {
                return nil
            }
            return [Coordinate(latitude: array[1], longitude: array[0])]
        case .lineString(let array):
            return array.compactMap {
                $0.count == 2 ? Coordinate(latitude: $0[1], longitude: $0[0]) : nil
            }
        }
    }
}

// MARK: - Properties
struct TMapFeaturePropertiesEntity: Codable, Entity {
    let index: Int?
    let lineIndex: Int?
    let pointIndex: Int?
    let name: String?
    let description: String?
    let direction: String?
    let nearPoiName: String?
    let nearPoiX: String?
    let nearPoiY: String?
    let intersectionName: String?
    let facilityType: String?
    let facilityName: String?
    let turnType: Int?
    let pointType: String?
    let totalDistance: Int?
    let totalTime: Int?
    let distance: Int?
    let time: Int?
    let roadType: Int?
    let categoryRoadType: Int?
    
    func map() -> (totalDistance: Int, totalTime: Int)? {
        guard let totalDistance = totalDistance, let totalTime = totalTime else {
            return nil
        }
        
        return (totalDistance, totalTime)
    }
}
