//
//  ButtonStyle.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/28/25.
//

import SwiftUI

// 공통 버튼 스타일
struct CommonStateButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }

}
