//
//  KakaoMapAPI.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/5/25.
//

import Foundation
import Moya

// 카카오 로컬 API
enum KakaoMapAPI: TargetType {
    case findAddress(_ address: String, page: Int = 1)
}

extension KakaoMapAPI {
    
    var baseURL: URL {
        URL(string: "https://dapi.kakao.com/v2/local/search")!
    }
    
    var path: String {
        switch self {
        case .findAddress:
            return "/address.json"
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
        case .findAddress(let address, let page):
            return .requestParameters(parameters: [
                "query": address,
                "page": page,
                "size": 30
            ], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var headers: [String: String] = ["Accept": "application/json"]
        
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "KakaoRestAPIKey") as? String {
            headers["Authorization"] = "KakaoAK \(apiKey)"
        }
        
        return headers
    }
    
}
