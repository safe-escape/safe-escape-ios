//
//  CrowdedAPI.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

enum CrowdedAPI {
    case getNearByCrowded(request: CrowdedNearByRequest)
    case getPrediction(request: CrowdedPredictionRequest)
}

extension CrowdedAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .getNearByCrowded:
            return URL(string: "https://terrapin-fresh-haddock.ngrok-free.app")!
        case .getPrediction:
            return URL(string: "https://6095d6084855.ngrok-free.app")!
        }
    }
    
    var path: String {
        switch self {
        case .getNearByCrowded:
            return "/api/populations/nearby"
        case .getPrediction:
            return "/predict"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getNearByCrowded:
            return .get
        case .getPrediction:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getNearByCrowded(let request):
            return .requestParameters(
                parameters: [
                    "latitude": request.latitude,
                    "longitude": request.longitude,
                    "size": request.size
                ],
                encoding: URLEncoding.queryString
            )
        case .getPrediction(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
