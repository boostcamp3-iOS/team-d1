//
//  URLSessionProtocol.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTaskProtocol
    
    func dataTask(with url: URL,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionTaskProtocol
}

extension URLSession: URLSessionProtocol {
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTaskProtocol {
            let task = dataTask(with: request,
                                completionHandler: completionHandler) as URLSessionDataTask
            return task as URLSessionDataTaskProtocol
    }
    
    func dataTask(with url: URL,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionTaskProtocol {
            let task = dataTask(with: url,
                                completionHandler: completionHandler) as URLSessionDataTask
            return task as URLSessionTaskProtocol
    }
}

extension URLSessionTask: URLSessionTaskProtocol {
    
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {
    
}

