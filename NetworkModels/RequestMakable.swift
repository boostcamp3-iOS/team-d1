//
//  requestBuildable.swift
//  BeBrav
//
//  Created by bumslap on 30/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol RequestMakable {
    
    func makeRequest(string: String, method: HTTPMethod, headers: [String: String], body: Data?) -> URLRequest?
}

extension RequestMakable {
    func makeRequest(string: String, method: HTTPMethod = .get, headers: [String: String] = [:], body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: string) else {
            return nil
        }
        var request = URLRequest(url: url)
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
        case .delete:
            request.httpMethod = method.rawValue
            return request
        default:
            return nil
        }
    }
}
