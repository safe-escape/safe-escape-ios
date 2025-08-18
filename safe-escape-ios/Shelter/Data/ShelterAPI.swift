//
//  ShelterAPI.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

enum ShelterAPI {
    case getBookmarkedShelters
    case addBookmark(shelterId: Int)    // 찜하기 (POST)
    case removeBookmark(shelterId: Int) // 찜 해제 (DELETE)
}

extension ShelterAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://terrapin-fresh-haddock.ngrok-free.app")!
    }
    
    var path: String {
        switch self {
        case .getBookmarkedShelters:
            return "/api/shelters/bookmark"
        case .addBookmark(let shelterId):
            return "/api/shelters/\(shelterId)/bookmark"
        case .removeBookmark(let shelterId):
            return "/api/shelters/\(shelterId)/bookmark"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getBookmarkedShelters:
            return .get
        case .addBookmark:
            return .post
        case .removeBookmark:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getBookmarkedShelters:
            return .requestPlain
        case .addBookmark:
            return .requestPlain
        case .removeBookmark:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        
        // JWT 토큰 추가 (인증이 필요한 API)
        if let token = TokenStorage.shared.getAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
}