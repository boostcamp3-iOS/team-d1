//
//  StorageWorker.swift
//  BeBrav
//
//  Created by bumslap on 01/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// NetworkSeparator는 NetworkSeperatable을 구현한 구조체로서 dispatcher, requestMaker
/// 를 프로퍼티로 받아서 url을 조합하고 requst를 생성하여 dispatcher를 호출, 네트워킹을 실행합니다.

import UIKit
import NetworkServiceProtocols
import Sharing

public struct NetworkSeparator: NetworkSeperatable {
    
    public let dispatcher: Dispatchable
    public let requestMaker: RequestMakable
    
    public init(dispatcher: Dispatchable, requestMaker: RequestMakable) {
        self.dispatcher = dispatcher
        self.requestMaker = requestMaker
    }
    
    public func read(path: String,
              headers: [String: String],
              queries: [URLQueryItem]? = nil,
              completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void) {
        guard var components = dispatcher.components else {
            completion(.failure(APIError.urlFailure), nil)
            return
        }
        components.queryItems = queries
        var url = components.url
        url?.appendPathComponent(path)
        
        guard let request = requestMaker.makeRequest(url: url,
                                                     method: .get,
                                                     headers: headers,
                                                     body: nil) else {
                                                        completion(.failure(APIError.requestFailed), nil)
                                                        return
        }
        dispatcher.dispatch(request: request) { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error), nil)
            case .success(let data):
                completion(.success(data), response)
            }
        }
    }
    
    // POST, PUT, PATCH 만 유효함
    public func write(path: String,
               data: Data,
               method: HTTPMethod,
               headers: [String: String],
               completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void) {
        var url = dispatcher.components?.url
        url?.appendPathComponent(path)
        guard let request = requestMaker.makeRequest(url: url?.asUrlWithoutEncoding(),
                                                     method: method,
                                                     headers: headers,
                                                     body: data) else {
                                                        completion(.failure(APIError.requestFailed), nil)
                                                        return
        }
        dispatcher.dispatch(request: request) { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error), response)
            case .success(let data):
                completion(.success(data), response)
            }
        }
    }
    
    public func delete(path: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> Void) {
        var url = dispatcher.components?.url
        url?.appendPathComponent(path)
        guard let request = requestMaker.makeRequest(url: url?.asUrlWithoutEncoding(),
                                                     method: .delete,
                                                     headers: [:],
                                                     body: nil) else {
                                                        completion(.failure(APIError.requestFailed))
                                                        return
        }
        dispatcher.dispatch(request: request) { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                completion(.success(response))
            }
        }
    }
}
