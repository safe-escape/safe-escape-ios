//
//  Formatter.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation

// 공통 거리 표시 Formatter
public enum DistanceFormatter {
    
    // 1km 미만은 m / 1km 이상은 km 단위로 소수점 이하 0 제외 첫째 자리까지 표시
    public static func format(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1fkm", meters / 1000).replacingOccurrences(of: ".0", with: "")
        }
    }
    
}

// 공통 시간 표시 Formatter
public enum TimeFormatter {
    
    // 초 단위 -> 00시간 00분으로 표시
    public static func format(_ seconds: Int) -> String {
        var seconds = seconds
        
        var hours = seconds / 3600
        seconds %= 3600
        
        var minutes = seconds / 60
        seconds %= 60
        
        if seconds > 0 {
            if minutes == 59 {
                hours += 1
                minutes = 0
            } else {
                minutes += 1
            }
        }
        
        var result = ""
        if hours > 0 {
            result += "\(hours)시간 "
        }
        
        if minutes > 0 {
            result += "\(minutes)분"
        }
        
        return result.trimmingCharacters(in: .whitespaces)
    }
    
}

public enum TopicFormatter {
    
    public static func appendTopicMarker(_ word: String) -> String {
        guard let lastChar = word.last else { return word }

        let scalar = lastChar.unicodeScalars.first!.value

        // 한글 유니코드 범위: 가(0xAC00) ~ 힣(0xD7A3)
        let base: UInt32 = 0xAC00
        let lastCharIndex = scalar - base

        // 받침이 있으면: index % 28 != 0
        let hasFinalConsonant = (lastCharIndex % 28) != 0

        let marker = hasFinalConsonant ? "은" : "는"
        return word + marker
    }
    
}
