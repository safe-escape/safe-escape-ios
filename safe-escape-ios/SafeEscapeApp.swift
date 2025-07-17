//
//  SafeEscapeApp.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/15/25.
//

import SwiftUI

@main
struct SafeEscapeApp: App {
    @State var showIntro: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if showIntro {
                IntroView(show: $showIntro)
            } else {
                ContentView()
            }
        }
    }
}
