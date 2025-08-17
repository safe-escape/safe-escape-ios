//
//  LogoutEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation

// 로그아웃 API 응답 Entity
struct LogoutResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: String?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}
