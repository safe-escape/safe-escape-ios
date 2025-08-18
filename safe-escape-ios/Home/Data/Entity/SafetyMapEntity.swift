//
//  SafetyMapEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation

struct SafetyMapResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: SafetyMapDataEntity?
    
    typealias DataEntity = SafetyMapDataEntity
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

struct SafetyMapDataEntity: Entity {
    let populationList: [PopulationEntity]
    let crowdedAreaList: [CrowdedAreaEntity]
    let shelterList: [ShelterEntity]
    let nearbyPopulation: NearbyPopulationEntity?
    
    typealias Model = SafetyMapData
    
    func map() -> SafetyMapData {
        return SafetyMapData(
            shelters: shelterList.map { $0.map() },
            crowded: populationList.map { $0.map() },
            crowdedAreas: crowdedAreaList.map { $0.map() },
            nearbyPopulation: nearbyPopulation?.map()
        )
    }
}

struct PopulationEntity: Entity {
    let latitude: Double
    let longitude: Double
    let level: String
    
    typealias Model = Crowded
    
    func map() -> Crowded {
        return Crowded(
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            level: CrowdedLevel(rawValue: level) ?? .normal
        )
    }
}

struct CrowdedAreaEntity: Entity {
    let id: Int
    let locationList: [LocationEntity]
    let exitList: [ExitEntity]
    
    typealias Model = CrowdedArea
    
    func map() -> CrowdedArea {
        return CrowdedArea(
            id: id,
            coordinates: locationList.map { Coordinate(latitude: $0.latitude, longitude: $0.longitude) },
            exits: exitList.map { $0.map() }
        )
    }
}

struct LocationEntity: Entity {
    let latitude: Double
    let longitude: Double
    
    typealias Model = Coordinate
    
    func map() -> Coordinate {
        return Coordinate(
            latitude: latitude,
            longitude: longitude
        )
    }
}

struct ExitEntity: Entity {
    let id: Int
    let latitude: Double
    let longitude: Double
    
    typealias Model = Exit
    
    func map() -> Exit {
        return Exit(
            id: id,
            coordinate: Coordinate(latitude: latitude, longitude: longitude)
        )
    }
}

struct ShelterEntity: Entity {
    let id: Int
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let bookmark: Bool
    
    typealias Model = Shelter
    
    func map() -> Shelter {
        return Shelter(
            id: id,
            name: name,
            address: address,
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            liked: bookmark
        )
    }
}

struct NearbyPopulationEntity: Entity {
    let name: String
    let latitude: Double
    let longitude: Double
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
