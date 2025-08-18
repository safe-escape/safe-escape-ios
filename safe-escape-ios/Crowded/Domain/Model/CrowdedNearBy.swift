//
//  CrowdedNearBy.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/28/25.
//

import Foundation
 
struct CrowdedNearBy: Identifiable {
    let id = UUID()
    let crowded: Crowded
    var address: String
}
