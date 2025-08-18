//
//  User.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import Foundation

// 사용자 정보
struct User {
    let id: String
    let name: String
    let email: String
    
    init(id: String = "", name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}