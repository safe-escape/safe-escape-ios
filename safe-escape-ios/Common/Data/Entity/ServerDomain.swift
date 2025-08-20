//
//  ServerDomain.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/21/25.
//

// 서버 도메인
enum ServerDomain {
    case API // 백엔드
    case AIModel // 백엔드 AI
    
    // 서버별 도메인 URL
    var baseURL: String {
        switch self {
        case .API:
            return "https://terrapin-fresh-haddock.ngrok-free.app"
        case .AIModel:
            return "https://6095d6084855.ngrok-free.app"
        }
    }
}
