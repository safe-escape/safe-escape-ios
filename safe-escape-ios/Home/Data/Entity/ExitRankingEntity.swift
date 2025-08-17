//
//  ExitRankingEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/17/25.
//

import Foundation

// 비상구 랭킹 요청 Entity
struct ExitRankingRequest: Codable {
    let entrances: [EntranceEntity]
    
    init(exits: [Exit]) {
        self.entrances = exits.map { exit in
            EntranceEntity(
                id: exit.id,
                latitude: exit.coordinate.latitude,
                longitude: exit.coordinate.longitude
            )
        }
    }
}

// 입구 정보 Entity
struct EntranceEntity: Codable {
    let id: Int
    let latitude: Double
    let longitude: Double
}

// 비상구 랭킹 응답 Entity
struct ExitRankingResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: ExitRankingDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 비상구 랭킹 데이터 Entity
struct ExitRankingDataEntity: Entity {
    let ranked_entrances: [EntranceEntity]
    
    typealias Model = [Exit]
    
    func map() -> [Exit] {
        return ranked_entrances.map {
            Exit(id: $0.id, coordinate: Coordinate(latitude: $0.latitude, longitude: $0.longitude))
        }
    }
}
