//
//  RequestMaker.swift
//  BeBrav
//
//  Created by bumslap on 31/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// RequestMaker는 RequestMakable을 구현한 구조체로 request가 필요한 모든 네트워크 모듈은
/// 이 구조체를 인스탠스화 하여 내부에서 이용해야합니다.

import Foundation

struct RequestMaker: RequestMakable {
    
    func makeRequest(url: URL?,
                     method: HTTPMethod = .get,
                     headers: [String: String] = [:],
                     body: Data? = nil) -> URLRequest? {
        
        guard let url = url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        print(request.url)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        
        switch method {
        case .get:
            return request
        case .post:
            request.httpMethod = method.rawValue
            return request
        case .patch:
            request.httpMethod = method.rawValue
            return request
        case .put:
            request.httpMethod = method.rawValue
            return request
        case .delete:
            request.httpMethod = method.rawValue
            return request
        }
    }
}
