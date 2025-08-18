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
    
    // 혼잡도 예상 조회 (421 에러 시 1회 재시도)
    func getPrediction(_ request: CrowdedPredictionRequest) async throws -> CrowdedPredictionDataEntity {
        return try await withCheckedThrowingContinuation { continuation in
            performPredictionRequest(request, continuation: continuation, retryCount: 0)
        }
    }
    
    private func performPredictionRequest(_ request: CrowdedPredictionRequest, continuation: CheckedContinuation<CrowdedPredictionDataEntity, Error>, retryCount: Int) {
        provider.request(.getPrediction(request: request)) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 421 && retryCount == 0 {
                    // 421 에러이고 첫 번째 시도인 경우 재시도
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        self.performPredictionRequest(request, continuation: continuation, retryCount: 1)
                    }
                } else {
                    continuation.resume(with: EntityConverter<CrowdedPredictionResponseEntity>.convert(response))
                }
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
