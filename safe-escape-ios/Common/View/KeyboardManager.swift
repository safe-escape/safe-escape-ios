//
//  KeyboardManager.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import Foundation
import UIKit
import Combine

// 키보드 show/hide 감지 매니저
class KeyboardManager: ObservableObject {
    @Published var showKeyboard = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillShowNotification)
            .sink { [weak self] _ in
                self?.showKeyboard = true
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.showKeyboard = false
            }
            .store(in: &cancellables)
    }
}
