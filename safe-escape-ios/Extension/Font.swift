//
//  Font.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/21/25.
//

import SwiftUI

extension Font {
    
    static func notosans(type: Weight, size: CGFloat) -> Font {
        var fontName = ""
        switch type {
            case .bold:
            fontName = "NotoSansKR-Bold"
            case .semibold:
            fontName = "NotoSansKR-SemiBold"
            case .medium:
            fontName = "NotoSansKR-Medium"
            default:
            fontName = "NotoSansKR-Regular"
        }
        return .custom(fontName, fixedSize: size)
    }
    
}
