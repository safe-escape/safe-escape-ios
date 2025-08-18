//
//  Date.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/28/25.
//

import Foundation

extension Date {
    
    func format() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // 안정적인 포맷팅을 위해 권장
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: self)
    }
    
}
