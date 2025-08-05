//
//  KakaoMapDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/5/25.
//

import Foundation
import Moya

// 카카오 로컬 API 관련 DataSource
class KakaoMapDataSource {
    static let shared = KakaoMapDataSource()
    
    private init() {}
    
    let provider = MoyaProvider<KakaoMapAPI>(plugins: [APICommonPlugin()])
    
    // 카카오 로컬 API -> Geocoding 주소 검색
    func findAddress(_ address: String, page: Int = 1) async throws -> (meta: KakaoGeocodingMetaEntity, address: [KakaoGeocodingDocumentEntity]) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.findAddress(address, page: page)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<KakaoGeocodingResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
