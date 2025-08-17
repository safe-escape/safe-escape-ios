//
//  CrowdedRepository.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/29/25.
//

import Foundation

// 혼잡도 Repository
class CrowdedRepository {
    static let shared = CrowdedRepository()
    
    private init() {}
    
    // 내 주변 혼잡한 지역 리스트 조회
    func getCrowdedNearByList(_ location: Coordinate) async throws -> [CrowdedNearBy] {
        let request = CrowdedNearByRequest(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        let dataEntities = try await CrowdedDataSource.shared.getNearByCrowded(request)
        return dataEntities.map { $0.map() }
    }
    
    // 혼잡도 예상 조회 (API 연결)
    func expectCrowded(_ location: Coordinate, _ date: Date) async throws -> (CrowdedLevel, PredictionLocation) {
        // 모든 위치의 ID를 요청에 포함
        let request = CrowdedPredictionRequest(date: date)
        
        let predictionData = try await CrowdedDataSource.shared.getPrediction(request)
        
        // API 응답에서 가장 가까운 지역을 찾기
        let nearestResult = findNearestPredictionFromResponse(
            predictions: predictionData.predictions,
            from: location
        )
        
        return nearestResult
    }
    
    // API 응답에서 가장 가까운 예측 지역과 혼잡도를 찾는 함수
    private func findNearestPredictionFromResponse(
        predictions: [CrowdedLocationPredictionEntity],
        from coordinate: Coordinate
    ) -> (CrowdedLevel, PredictionLocation) {
        var nearestLocation = PredictionLocation.locations[0]
        var nearestCrowdedLevel = CrowdedLevel.normal
        var minDistance = Double.infinity
        
        // 예측 결과를 순회하며 가장 가까운 지역 찾기
        for prediction in predictions {
            if let location = PredictionLocation.locations.first(where: { Int($0.id) == prediction.location }) {
                let distance = LocationUsecase.shared.getDirectDistance(from: coordinate, to: location.coordinate)
                
                if distance < minDistance {
                    minDistance = distance
                    nearestLocation = location
                    nearestCrowdedLevel = CrowdedLevel.allCases[safe: prediction.congestion_level] ?? .normal
                }
            }
        }
        
        return (nearestCrowdedLevel, nearestLocation)
    }
    
    // 혼잡도 예상 Default Text용 - 내일 오후 3시 데이터로 상위 혼잡한 지역들 찾기
    func getDefaultExpectedText() async throws -> [(CrowdedLevel, PredictionLocation)] {
        // 내일 오후 6시 Date 생성
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let tomorrowAt6PM = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        
        let request = CrowdedPredictionRequest(date: tomorrowAt6PM)
        let predictionData = try await CrowdedDataSource.shared.getPrediction(request)
        
        // 상위 3개의 혼잡한 지역과 높은 확률을 가진 예측 찾기
        let topCrowdedResults = findTopCrowdedPredictions(predictions: predictionData.predictions, count: 3)
        
        return topCrowdedResults
    }
    
    // 가장 혼잡하고 확률이 높은 예측 지역 찾기
    private func findMostCrowdedPrediction(
        predictions: [CrowdedLocationPredictionEntity]
    ) -> (CrowdedLevel, PredictionLocation) {
        var bestLocation = PredictionLocation.locations[0]
        var bestCrowdedLevel = CrowdedLevel.normal
        var highestCongestionLevel = -1
        var highestProba = 0.0
        
        for prediction in predictions {
            // congestion_level이 더 높거나, 같은 레벨에서 확률이 더 높은 경우
            let currentProba = prediction.proba[String(prediction.congestion_level)] ?? 0.0
            
            let shouldUpdate = prediction.congestion_level > highestCongestionLevel || 
                             (prediction.congestion_level == highestCongestionLevel && currentProba > highestProba)
            
            if shouldUpdate,
               let location = PredictionLocation.locations.first(where: { Int($0.id) == prediction.location }) {
                highestCongestionLevel = prediction.congestion_level
                highestProba = currentProba
                bestLocation = location
                bestCrowdedLevel = CrowdedLevel.allCases[safe: prediction.congestion_level] ?? .normal
            }
        }
        
        return (bestCrowdedLevel, bestLocation)
    }
    
    // 가장 혼잡한 지역 1개 + 가장 안 혼잡한 지역 1개 + 랜덤 1개 선택
    private func findTopCrowdedPredictions(
        predictions: [CrowdedLocationPredictionEntity],
        count: Int
    ) -> [(CrowdedLevel, PredictionLocation)] {
        // 각 예측에 대해 점수 계산 (혼잡도 레벨 * 확률)
        let scoredPredictions = predictions.compactMap { prediction -> (CrowdedLevel, PredictionLocation, Double)? in
            guard let location = PredictionLocation.locations.first(where: { Int($0.id) == prediction.location }) else {
                return nil
            }
            
            let crowdedLevel = CrowdedLevel.allCases[safe: prediction.congestion_level] ?? .normal
            let probability = prediction.proba[String(prediction.congestion_level)] ?? 0.0
            
            // 점수 = 혼잡도 레벨 (0-3) * 확률 (0-1) * 100
            let score = Double(prediction.congestion_level) * probability * 100
            
            return (crowdedLevel, location, score)
        }
        
        guard scoredPredictions.count >= 3 else { return scoredPredictions.map { ($0.0, $0.1) } }
        
        // 점수 순으로 정렬 (높은 점수부터)
        let sortedPredictions = scoredPredictions.sorted { $0.2 > $1.2 }
        
        var result: [(CrowdedLevel, PredictionLocation)] = []
        
        // 1. 가장 혼잡한 지역 (첫 번째)
        let mostCrowded = sortedPredictions.first!
        result.append((mostCrowded.0, mostCrowded.1))
        
        // 2. 가장 안 혼잡한 지역 (마지막)
        let leastCrowded = sortedPredictions.last!
        result.append((leastCrowded.0, leastCrowded.1))
        
        // 3. 나머지 중간 지역들에서 랜덤 1개
        let middlePredictions = Array(sortedPredictions.dropFirst().dropLast())
        if !middlePredictions.isEmpty {
            let randomMiddle = middlePredictions.randomElement()!
            result.append((randomMiddle.0, randomMiddle.1))
        }
        
        return result
    }
}
