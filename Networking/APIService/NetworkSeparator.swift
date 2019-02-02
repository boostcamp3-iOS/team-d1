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

struct NetworkSeparator: NetworkSeperatable {
    
    let dispatcher: Dispatchable
    let requestMaker: RequestMakable
    
    init(worker: Dispatchable, requestMaker: RequestMakable) {
        self.dispatcher = worker
        self.requestMaker = requestMaker
    }
    
    func read(path: String, completion: @escaping (Result<Data>, URLResponse?) -> Void) {
        var url = dispatcher.baseUrl
        url?.appendPathComponent(path)
        guard let request = requestMaker.makeRequest(url: url?.asUrlWithoutEncoding(), method: .get, headers: [:], body: nil) else {
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
    func write(path: String, data: Data, method: HTTPMethod,
               headers: [String: String],
               completion: @escaping (Result<Data>, URLResponse?) -> Void) {
        var url = dispatcher.baseUrl
        url?.appendPathComponent(path)
        guard let request = requestMaker.makeRequest(url: url?.asUrlWithoutEncoding(),
                                                     method: method,
                                                     headers: ["Content-Type": MimeType.json.rawValue],
                                                     body: data) else {
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
    
    func delete(path: String,
                completion: @escaping (Result<URLResponse?>) -> Void) {
        var url = dispatcher.baseUrl
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
