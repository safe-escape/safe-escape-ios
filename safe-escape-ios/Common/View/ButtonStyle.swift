//
//  ButtonStyle.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/28/25.
//

import SwiftUI

struct CommonStateButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }

}
