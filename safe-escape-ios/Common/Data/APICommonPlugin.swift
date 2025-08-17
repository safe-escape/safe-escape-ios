//
//  APICommonPlugin.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/24/25.
//

import Foundation
import Moya
import Alamofire

fileprivate let doNotRetryWithErrorCode = "DoNotRetryWithErrorCode"
let timeoutErrorCode = "TimeoutErrorCode"

var networkCompletion: (() -> Void)?

class APICommonPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var urlRequest = request
        urlRequest.timeoutInterval = 30
        return urlRequest
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
          print("--> 유효하지 않은 요청")
          return
        }
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"
        var log = "============= API CALL =============\n"
        log.append("[\(method)] \(url.removingPercentEncoding ?? url)\n")
        log.append("API: \(target)\n")
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("header: \(headers)\n")
        }
        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
          log.append("body: \(bodyString)\n")
        }
        log.append("============= END CALL =============")
        NSLog("[API] \(log)")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print(response)
        case .failure(let error):
            print(error)
        }
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        return result
    }
}

func handleTimeoutError(_ error: Error) -> Bool {
    if let moyError = error as? MoyaError, case .underlying(let afError, _) = moyError, case .requestRetryFailed(retryError: let retryError, originalError: _) = afError.asAFError, (retryError as? ErrorDisplay)?.code == timeoutErrorCode {
        return true
    }
    
    return false
}
