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

// 주어 - 은/는 조사 Formatter
public enum TopicFormatter {
    private static let numberToHangul: [Character: String] = [
        "0": "십", "1": "일", "2": "이", "3": "삼", "4": "사",
        "5": "오", "6": "육", "7": "칠", "8": "팔", "9": "구"
    ]

    // 주어 받침 여부에 따라 은/는 조사 반환
    public static func getTopicMarker(_ word: String) -> String {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastChar = trimmed.last else { return "는" }

        let lastCharStr: String

        if lastChar.isNumber, let hangul = numberToHangul[lastChar] {
            lastCharStr = hangul
        } else {
            lastCharStr = String(lastChar)
        }

        guard let scalar = lastCharStr.unicodeScalars.first?.value,
              scalar >= 0xAC00 && scalar <= 0xD7A3 else {
            return "는" // 한글이 아닌 경우 기본적으로 "는"
        }

        let base: UInt32 = 0xAC00
        let lastCharIndex = scalar - base

        // 받침이 있는 경우 index % 28 != 0
        let hasFinalConsonant = (lastCharIndex % 28) != 0
        return hasFinalConsonant ? "은" : "는"
    }
}


// 주어 - 이/가 조사 Formatter
public enum SubjectFormatter {
    private static let numberToHangul: [Character: String] = [
        "0": "십", "1": "일", "2": "이", "3": "삼", "4": "사",
        "5": "오", "6": "육", "7": "칠", "8": "팔", "9": "구"
    ]

    // 주어 받침 여부에 따라 이/가 조사 반환
    public static func getSubjectMarker(_ word: String) -> String {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastChar = trimmed.last else { return "가" }

        let lastCharStr: String

        if lastChar.isNumber, let hangul = numberToHangul[lastChar] {
            lastCharStr = hangul
        } else {
            lastCharStr = String(lastChar)
        }

        guard let scalar = lastCharStr.unicodeScalars.first?.value,
              scalar >= 0xAC00 && scalar <= 0xD7A3 else {
            return "가" // 한글이 아니면 기본적으로 "가"
        }

        let base: UInt32 = 0xAC00
        let lastCharIndex = scalar - base

        // 받침 여부 판별
        let hasFinalConsonant = (lastCharIndex % 28) != 0
        return hasFinalConsonant ? "이" : "가"
    }
}
