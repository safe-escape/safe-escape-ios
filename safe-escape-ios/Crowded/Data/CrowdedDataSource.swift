//
//  CrowdedDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

class CrowdedDataSource {
    static let shared = CrowdedDataSource()
    
    private init() {}

    let provider = MoyaProvider<CrowdedAPI>(plugins: [APICommonPlugin()])
    
    // 주변 혼잡 지역 조회
    func getNearByCrowded(_ request: CrowdedNearByRequest) async throws -> [CrowdedNearByDataEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getNearByCrowded(request: request)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<CrowdedNearByResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 혼잡도 예상 조회
    func getPrediction(_ request: CrowdedPredictionRequest) async throws -> CrowdedPredictionDataEntity {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getPrediction(request: request)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<CrowdedPredictionResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
