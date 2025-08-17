//
//  EntityConverter.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/22/25.
//

import Foundation
import Moya

// Entity Converter
class EntityConverter<T: ResponseEntity> {
    
    // Moya Response Convert to Entity
    static func convert(_ response: Response) -> Result<T.DataEntity, Error> {
        NSLog("[API] EntityConverter json: \((try? response.mapJSON()) ?? "JSON Parse Error") \nstatusCode:\(response.statusCode)\ndescription:\(response.description)")
        
        guard let returnItem = try? response.map(T.self)
        else {
            // 제네릭 바인딩 실패 시 공통 에러 응답으로 재시도
            if let commonErrorItem = try? response.map(CommonErrorResponseEntity.self) {
                // 공통 에러 응답 바인딩 성공 시 에러 코드별 처리
                switch commonErrorItem.code.uppercased() {
                case "EXPIRED_JWT":
                    return .failure(EntityConverterError.expiredJWT(request: response.request))
                case "EXPIRED_REFRESH_TOKEN":
                    return .failure(EntityConverterError.expiredRefreshToken(request: response.request))
                default:
                    // 기타 API 에러는 code 값과 함께 전달
                    return .failure(EntityConverterError.apiError(code: commonErrorItem.code, request: response.request))
                }
            } else {
                if T.self is APIErrorCode.Type, response.statusCode == 403 {
                    return .failure(EntityConverterError.expiredJWT(request: response.request))
                }
                
                return .failure(EntityConverterError.failParsing(data: "statusCode: \(response.statusCode)\ndescription: \(response.description)\ndata: \((try? response.mapJSON()) ?? "JSON Parse Error")", request: response.request))
            }
        }
        
        if returnItem.success == false {
            // 에러 코드별 처리
            if let responseEntity = returnItem as? (any ResponseEntity & APIErrorCode) {
                switch responseEntity.code.uppercased() {
                case "EXPIRED_JWT":
                    return .failure(EntityConverterError.expiredJWT(request: response.request))
                case "EXPIRED_REFRESH_TOKEN":
                    return .failure(EntityConverterError.expiredRefreshToken(request: response.request))
                default:
                    // 기타 API 에러는 code 값과 함께 전달하여 상위에서 처리
                    return .failure(EntityConverterError.apiError(code: responseEntity.code, request: response.request))
                }
            } else {
                return .failure(EntityConverterError.failParsing(data: "", request: response.request))
            }
        } else if let data = returnItem.data {
            return .success(data)
        } else {
            return .failure(EntityConverterError.failRequest(data: "statusCode: \(response.statusCode)\ndescription: \(response.description)\ndata: \((try? response.mapJSON()) ?? "JSON Parse Error")", request: response.request))
        }
    }
    
    // Moya Response Convert to No Data Entity
    static func convertNoData(_ response: Response) -> Result<Bool, Error> {
        NSLog("[API] EntityConverter json: \((try? response.mapJSON()) ?? "JSON Parse Error") \nstatusCode:\(response.statusCode)\ndescription:\(response.description)")
        
        guard let returnItem = try? response.map(T.self)
        else {
            // 제네릭 바인딩 실패 시 공통 에러 응답으로 재시도
            if let commonErrorItem = try? response.map(CommonErrorResponseEntity.self) {
                // 공통 에러 응답 바인딩 성공 시 에러 코드별 처리
                switch commonErrorItem.code.uppercased() {
                case "EXPIRED_JWT":
                    return .failure(EntityConverterError.expiredJWT(request: response.request))
                case "EXPIRED_REFRESH_TOKEN":
                    return .failure(EntityConverterError.expiredRefreshToken(request: response.request))
                default:
                    // 기타 API 에러는 code 값과 함께 전달
                    return .failure(EntityConverterError.apiError(code: commonErrorItem.code, request: response.request))
                }
            } else {
                return .failure(EntityConverterError.failParsing(data: "statusCode: \(response.statusCode)\ndescription: \(response.description)\ndata: \((try? response.mapJSON()) ?? "JSON Parse Error")", request: response.request))
            }
        }
        
        if returnItem.success == false {
            // 에러 코드별 처리
            if let responseEntity = returnItem as? (any ResponseEntity & APIErrorCode) {
                switch responseEntity.code.uppercased() {
                case "EXPIRED_JWT":
                    return .failure(EntityConverterError.expiredJWT(request: response.request))
                case "EXPIRED_REFRESH_TOKEN":
                    return .failure(EntityConverterError.expiredRefreshToken(request: response.request))
                default:
                    // 기타 API 에러는 code 값과 함께 전달
                    return .failure(EntityConverterError.apiError(code: responseEntity.code, request: response.request))
                }
            } else {
                return .failure(EntityConverterError.failParsing(data: "", request: response.request))
            }
        } else if response.statusCode == 200 {
            return .success(true)
        } else {
            return .failure(EntityConverterError.failRequest(data: "statusCode: \(response.statusCode)\ndescription: \(response.description)\ndata: \((try? response.mapJSON()) ?? "JSON Parse Error")", request: response.request))
        }
    }
    
}
