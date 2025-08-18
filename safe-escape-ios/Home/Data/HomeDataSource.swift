//
//  HomeDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/14/25.
//

import Foundation
import Moya

// 네이버 Maps API 관련 DataSource
class HomeDataSource {
    static let shared = HomeDataSource()
    
    private init() {}

    let provider = MoyaProvider<HomeAPI>(plugins: [APICommonPlugin()])
    
    // 홈 데이터 지도 조회
    func getData(bounds: MapBounds) async throws -> SafetyMapDataEntity {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getMapData(bounds)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<SafetyMapResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 비상구 랭킹 조회 (421 에러 시 1회 재시도)
    func rankExits(_ exits: [Exit]) async throws -> ExitRankingDataEntity {
        let request = ExitRankingRequest(exits: exits)
        return try await withCheckedThrowingContinuation { continuation in
            performRankExitsRequest(request, continuation: continuation, retryCount: 0)
        }
    }
    
    private func performRankExitsRequest(_ request: ExitRankingRequest, continuation: CheckedContinuation<ExitRankingDataEntity, Error>, retryCount: Int) {
        provider.request(.rankExits(request)) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 421 && retryCount == 0 {
                    // 421 에러이고 첫 번째 시도인 경우 재시도
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        self.performRankExitsRequest(request, continuation: continuation, retryCount: 1)
                    }
                } else {
                    continuation.resume(with: EntityConverter<ExitRankingResponseEntity>.convert(response))
                }
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
    
}
