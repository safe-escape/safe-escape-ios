//
//  Error.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

struct ErrorDisplay: Error {
    var code: String?
    var msg: String?
    var req: URLRequest?
}


// Data Layer error
enum EntityConverterError: Error {
    case failParsing(data: String?, request: URLRequest?) // entity parse error
    case failRequest(data: String?, request: URLRequest?) // request error
}
