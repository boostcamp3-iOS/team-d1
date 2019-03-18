//
//  URLSessionProtocol.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponseProtocol?, Error?) -> Void) -> URLSessionTaskProtocol
    
    
    func dataTask(with url: URL,
                  completionHandler: @escaping (Data?, URLResponseProtocol?, Error?) -> Void)
        -> URLSessionTaskProtocol
}

extension URLSession: URLSessionProtocol {
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponseProtocol?, Error?) -> Void) -> URLSessionTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionTaskProtocol
    }
    
    public func dataTask(with url: URL,
                  completionHandler: @escaping (Data?, URLResponseProtocol?, Error?) -> Void)
        -> URLSessionTaskProtocol {
            
            return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as  URLSessionTaskProtocol
    }
}

extension URLSessionTask: URLSessionTaskProtocol {
    
}
