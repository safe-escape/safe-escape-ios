//
//  Error.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

struct ErrorDisplay: Error {
    var code: String?
    var msg: String?
    var req: URLRequest?
}


// Data Layer error
enum EntityConverterError: Error {
    case failParsing(data: String?, request: URLRequest?) // entity parse error
    case failRequest(data: String?, request: URLRequest?) // request error
    case expiredJWT(request: URLRequest?) // JWT 토큰 만료 (자동 처리)
    case expiredRefreshToken(request: URLRequest?) // Refresh 토큰 만료 (자동 처리)
    case apiError(code: String, request: URLRequest?) // 기타 API 에러 (코드별 개별 처리)
}

