//
//  MemberEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation

// 회원 정보 조회 API 응답 Entity
struct MemberResponseEntity: ResponseEntity, APIErrorCode {
    let code: String
    let data: MemberDataEntity?
    
    var success: Bool {
        return code.uppercased() == "OK"
    }
}

// 회원 정보 데이터 Entity
struct MemberDataEntity: Entity {
    let id: Int
    let name: String
    let email: String
    
    typealias Model = User
    
    func map() -> User {
        return User(
            id: String(id),
            name: name,
            email: email
        )
    }
}