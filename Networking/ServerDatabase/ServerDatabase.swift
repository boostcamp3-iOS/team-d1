
//
//  DataBase.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct ServerDataBase: APIService, PathMaker, RequestMakable {
    
    var pathString: String = FirebaseEndPoint.shared.dataBaseBaseURL
    
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    mutating func addPath(_ path: String) {
        pathString += "/\(path).json"
    }
    
    func fetchData<T: Decodable>(by decodeType: T.Type, _ completion: @escaping (Result<T>, URLResponse?)->()) {
        print(pathString)
        guard let request = makeRequest(string: pathString, headers: ["Content-Type": MimeType.json.rawValue]) else {
            completion(.failure(APIError.requestFailed), nil)
            return
        }
        fetch(with: request, decodeType: decodeType) { (result, response) in
            switch result {
            case .success(let data):
                completion(.success(data), response)
            case.failure(let error):
                completion(.failure(error), response)
            }
        }
    }
    
    func setData<T: Encodable>(data: T, _ completion: @escaping (Result<URLResponse?>)->()) {
        guard let data = extractEncodedJsonData(data: data) else {
            completion(.failure(APIError.jsonParsingFailure))
            return
        }
        guard let request = makeRequest(string: pathString, method: .post, headers: ["Content-Type": MimeType.json.rawValue], body: data) else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(let response):
                completion(.success(response))
            }
        }
        task.resume()
    }

    func updateData<T: Encodable>(data: T, _ completion: @escaping (Result<URLResponse?>)->()) {
        guard let data = extractEncodedJsonData(data: data) else {
            completion(.failure(APIError.jsonParsingFailure))
            return
        }
        guard let request = makeRequest(string: pathString, method: .patch, headers: ["Content-Type": MimeType.json.rawValue], body: data) else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(let response):
                completion(.success(response))
            }
        }
        task.resume()
    }
    
    //deleteData와 다른 메서드 간의 의존성에 주의하세요! 비동기 상황에서 어느것이 먼저 실행될 지 모르므로 핸들러를 이용해주세요
    func deleteData(_ completion: @escaping (Result<URLResponse?>)->()) {
        guard let request = makeRequest(string: pathString, method: .delete, headers: ["Content-Type": MimeType.json.rawValue]) else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(let response):
                completion(.success(response))
            }
        }
        task.resume()
    }
}
