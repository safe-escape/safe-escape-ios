//
//  Untitled.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation
import Moya

// SK Open API - TMAP API
enum TMapAPI: TargetType {
    case findPedestrianRoute(_ start: Coordinate, _ end: Coordinate) // 보행자 도로 경로 검색
}

extension TMapAPI {
    var baseURL: URL {
        return URL(string: "https://apis.openapi.sk.com/tmap")!
    }
    
    var path: String {
        switch self {
        case .findPedestrianRoute:
            return "/routes/pedestrian"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        switch self {
        case .findPedestrianRoute(let start, let end):
            return .requestCompositeParameters(bodyParameters: ["startName": "출발지",
                                                                "startX": start.longitude,
                                                                "startY": start.latitude,
                                                                "endName": "도착지",
                                                                "endX": end.longitude,
                                                                "endY": end.latitude,
                                                                "reqCoordType": "WGS84GEO",
                                                                "resCoordType": "WGS84GEO"],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: ["version": "1"])
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [
            "accept": "application/json",
            "content-type": "application/json",
        ]
        
        if let appKey = Bundle.main.object(forInfoDictionaryKey: "TMapAppKey") as? String {
            headers["appKey"] = appKey
        }
        
        return headers
    }
}
