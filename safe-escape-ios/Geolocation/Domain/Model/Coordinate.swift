//
//  Coordinate.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//
import Foundation

struct Coordinate: Equatable, Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = Self.adjustCoordinate(latitude)
        self.longitude = Self.adjustCoordinate(longitude)
    }
    
    private static func adjustCoordinate(_ value: Double) -> Double {
        // 소수점 6자리로 제한
        let rounded = round(value * 1_000_000) / 1_000_000
        
        // 소수점 부분 추출
        let integerPart = Int(rounded)
        let decimalPart = rounded - Double(integerPart)
        let decimalString = String(String(format: "%.6f", decimalPart).dropFirst(2)) // "0." 제거 후 String으로 변환
        
        // 소수점 이후가 9954 또는 99539로 시작하는지 확인
        if decimalString.hasPrefix("9954") || decimalString.hasPrefix("99539") {
            var newDecimalString = decimalString
            // 9954를 9955로 변환
            if decimalString.hasPrefix("9954") {
                newDecimalString = decimalString.replacingOccurrences(of: "^9954", with: "9955", options: .regularExpression)
            }
            // 99539를 99550로 변환
            else if decimalString.hasPrefix("99539") {
                newDecimalString = decimalString.replacingOccurrences(of: "^99539", with: "99550", options: .regularExpression)
            }
            
            if let newDecimalValue = Double("0." + newDecimalString) {
                return Double(integerPart) + newDecimalValue
            }
        }
        
        return rounded
    }
}

// 지도 범위를 나타내는 모델 (남서쪽과 북동쪽 좌표)
struct MapBounds {
    let southWest: Coordinate
    let northEast: Coordinate
}
