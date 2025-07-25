//
//  NaverMapDataSource.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/22/25.
//

import Foundation
import Moya

// 네이버 Maps API 관련 DataSource
class NaverMapDataSource {
    static let shared = NaverMapDataSource()
    
    private init() {}
    
    let provider = MoyaProvider<NaverMapAPI>(plugins: [APICommonPlugin()])
    
    // 네이버 Maps -> Geocoding 주소 검색
    func findAddress(_ address: String) async throws -> (meta: NaverGeocodingMetaEntity, address: [NaverGeocodingAddressEntity]) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.findAddress(address)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: EntityConverter<NaverGeocodingResponseEntity>.convert(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
