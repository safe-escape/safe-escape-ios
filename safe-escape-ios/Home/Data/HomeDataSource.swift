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
    
    // 비상구 랭킹 조회
    func rankExits(_ exits: [Exit]) async throws -> ExitRankingDataEntity {
        let request = ExitRankingRequest(exits: exits)
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.rankExits(request)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<ExitRankingResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
