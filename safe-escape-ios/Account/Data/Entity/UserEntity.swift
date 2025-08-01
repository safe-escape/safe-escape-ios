//
//  UserEntity.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 사용자 Entity
struct UserEntity: Entity {
    let id: String
    let name: String
    let email: String
    
    func map() -> User {
        return User(
            id: id,
            name: name,
            email: email
        )
    }
}