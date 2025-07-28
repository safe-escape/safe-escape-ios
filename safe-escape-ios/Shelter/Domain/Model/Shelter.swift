//
//  Shelter.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

// 대피소
struct Shelter: Identifiable {
    var id: String // ID
    var name: String // 이름
    var address: String // 주소
    var coordinate: Coordinate // 좌표
    var distance: Double! = nil // 거리
    var liked: Bool // 찜 여부
}
