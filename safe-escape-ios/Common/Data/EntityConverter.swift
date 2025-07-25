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
        else { return .failure(EntityConverterError.failParsing(data: "statusCode: \(response.statusCode)\ndescription: \(response.description)\ndata: \((try? response.mapJSON()) ?? "JSON Parse Error")", request: response.request)) }
        
        if returnItem.success == false {
            return .failure(EntityConverterError.failParsing(data: "", request: response.request))
        } else if let data = returnItem.data {
            return .success(data)
        } else {
            return .failure(EntityConverterError.failRequest(data: "statusCode: \(response.statusCode)\ndescription: \(response.description)\ndata: \((try? response.mapJSON()) ?? "JSON Parse Error")", request: response.request))
        }
    }
    
}
