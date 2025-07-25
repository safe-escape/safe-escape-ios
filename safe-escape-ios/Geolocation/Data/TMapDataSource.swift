//
//  TMapDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation
import Moya

// SK Open API - TMAP API Data Source
class TMapDataSource {
    static let shared = TMapDataSource()
    
    private init() {}
    
    private let provider: MoyaProvider<TMapAPI> = MoyaProvider<TMapAPI>(plugins: [APICommonPlugin()])
    
    // 보행자 도로 경로 검색
    func findRoute(_ start: Coordinate, _ end: Coordinate) async throws -> [TMapFeatureEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.findPedestrianRoute(start, end)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<TMapPedestrianEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
