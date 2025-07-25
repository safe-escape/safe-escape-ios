//
//  Entity.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

// 최상위 응답 Entity
protocol ResponseEntity: Codable {
    // 성공 여부
    var success: Bool { get }
    
    // 데이터로 변환할 Data Entity 타입 지정 필요
    associatedtype DataEntity
    var data: DataEntity? { get }
}

// 각 데이터 Enity
protocol Entity: Codable {
    // 변경할 Domain Model 타입 지정 및 변환
    associatedtype Model
    func map() -> Model
}
