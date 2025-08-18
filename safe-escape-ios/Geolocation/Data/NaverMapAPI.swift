//
//  NaverMapAPI.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/22/25.
//

import Foundation
import Moya

// 네이버 Maps API
enum NaverMapAPI: TargetType {
    case findAddress(_ address: String) // 주소 검색
}

extension NaverMapAPI {
    
    var baseURL: URL {
        URL(string: "https://maps.apigw.ntruss.com/map-geocode/v2")!
    }
    
    var path: String {
        switch self {
        case .findAddress:
            return "/geocode"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .findAddress:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .findAddress(let address):
            return .requestParameters(parameters: ["query": address, "count": 100], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = ["Accept": "application/json"]
        
        if let keyId = Bundle.main.object(forInfoDictionaryKey: "NMFNcpKeyId") as? String {
            headers["x-ncp-apigw-api-key-id"] = keyId
        }
        
        if let key = Bundle.main.object(forInfoDictionaryKey: "NMFNcpKey") as? String {
            headers["x-ncp-apigw-api-key"] = key
        }
        
        return headers
    }
    
}
