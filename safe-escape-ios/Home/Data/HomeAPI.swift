//
//  HomeAPI.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

// 네이버 Maps API
enum HomeAPI: TargetType {
    case getMapData(_ req: MapBounds) // 메인 지도 데이터 조회
    case rankExits(_ request: ExitRankingRequest) // 비상구 랭킹 조회
}

extension HomeAPI {
    
    var baseURL: URL {
        switch self {
        case .getMapData:
            return URL(string: ServerDomain.API.baseURL)!
        case .rankExits:
            return URL(string: ServerDomain.AIModel.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .getMapData(let req):
            let bounds = [
                Coordinate(latitude: req.northEast.latitude, longitude: req.southWest.longitude),
                Coordinate(latitude: req.southWest.latitude, longitude: req.southWest.longitude),
                Coordinate(latitude: req.southWest.latitude, longitude: req.northEast.longitude),
                Coordinate(latitude: req.northEast.latitude, longitude: req.northEast.longitude),
            ]
            
            let query = bounds.map {
                "latitudes=\($0.latitude)&longitudes=\($0.longitude)"
            }.joined(separator: "&")
            
            return "/api/main"
        case .rankExits:
            return "/rank_exits"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMapData:
            return .get
        case .rankExits:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMapData(let req):
            let bounds = [
                Coordinate(latitude: req.northEast.latitude, longitude: req.southWest.longitude),
                Coordinate(latitude: req.southWest.latitude, longitude: req.southWest.longitude),
                Coordinate(latitude: req.southWest.latitude, longitude: req.northEast.longitude),
                Coordinate(latitude: req.northEast.latitude, longitude: req.northEast.longitude),
            ]
            
            var parameters: [String: [String]] = [
                "latitudes": [],
                "longitudes": []
            ]
            
            for coordinate in bounds {
                parameters["latitudes"]?.append("\(coordinate.latitude)")
                parameters["longitudes"]?.append("\(coordinate.longitude)")
            }

            // 플랫하게 펼치기
            let flatParams = parameters.flatMap { key, values in
                values.map { value in (key, value) }
            }

            // [("latitudes", "37.1"), ("longitudes", "127.1"), ...]
            let finalParams = Dictionary(grouping: flatParams, by: { $0.0 })
                .mapValues { $0.map { $0.1 } }

            return .requestParameters(
                parameters: finalParams,
                encoding: URLEncoding(destination: .queryString,
                                      arrayEncoding: .noBrackets,
                                      boolEncoding: .literal)
            )
        case .rankExits(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = [
            "Accept": "application/json",
        ]
        
        // 로그인되어 있으면 Access Token 추가
        if let accessToken = TokenStorage.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
    
}
