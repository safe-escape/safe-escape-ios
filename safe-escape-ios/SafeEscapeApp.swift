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
    @StateObject var navigationViewModel: NavigationViewModel = .init()
    @StateObject var keyboardManager: KeyboardManager = .init()
    @StateObject var authManager: AuthenticationManager = .init()
    
    var body: some Scene {
        WindowGroup {
            if showIntro {
                IntroView(show: $showIntro)
                    .onAppear {
                        authManager.checkAutoLogin()
                    }
            } else {
                MainView()
                    .environmentObject(navigationViewModel)
                    .environmentObject(keyboardManager)
                    .environmentObject(authManager)
            }
        }
    }
}
