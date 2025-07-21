//
//  Color.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/18/25.
//

import SwiftUI

extension Color {
    
    init?(hexCode: String?) {
        guard let hex = hexCode else { return nil}
        self.init(hex: hex)
    }
    
    init?(hex: String) {
        guard let rgb = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else { return nil }
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
    
    init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red) / 255.0,
                  green: Double(green) / 255.0,
                  blue: Double(blue) / 255.0)
    }
    
}
