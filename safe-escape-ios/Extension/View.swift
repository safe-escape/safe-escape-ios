//
//  View.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/18/25.
//

import SwiftUI

extension View {
    
    var safeAreaTop: CGFloat {
        return UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .safeAreaInsets.top ?? 0
    }

    var safeAreaBottom: CGFloat {
        return UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .safeAreaInsets.bottom ?? 0
    }

    var maxHeight: CGFloat {
        UIScreen.main.bounds.height - safeAreaTop - safeAreaBottom
    }
    
}
