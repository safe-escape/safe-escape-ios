//
//  HomeViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI

struct ShelterInfo {
    var name: String
    var address: String
    var distance: Double
    var liked: Bool
}

struct ExitInfo {
    var distance: Double
    var eta: Int
}

class ExitInfoViewModel: ObservableObject {
    @Published var data: ExitInfo? = nil
}

enum ExitInfoState {
    case idle // 비상구 추천 여부 미정
    case loading // 찾는 중
    case complete // 비상구 찾음
}

class HomeViewModel: ObservableObject {
    
    @Published var currentUserLocation: (Double, Double)? = nil
    
    @Published var textInputAddress: String = ""
    
    @Published var showShelterInfo: Bool = false
    var shelterInfo: ShelterInfo? = ShelterInfo(name: "인수동 자치회관", address: "서울특별시 강북구 인수봉로 255", distance: 198, liked: false)
    
    @Published var showExitInfo: Bool = false
    var exitInfo: ExitInfo? = nil
    
    @Published var showCurrentUserLocation: Bool = false
    
    
}
