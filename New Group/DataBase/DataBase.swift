//
//  DataBase.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class DataBase: APIService {
    typealias JsonDict = [String: Any]
    let session: URLSession
    static let dataBase = DataBase()
    private var currentURL: String = baseURL
    
    
    private init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    private convenience init() {
        self.init(configuration: .default)
        //self.session.configuration.timeoutIntervalForRequest = 10.0
        //self.session.configuration.timeoutIntervalForResource = 15.0
    }
    
    func child(_ name: String) -> DataBase {
        assert(!name.contains("/"), "no '/' in the String")
        if currentURL.contains(".json") {
             currentURL = currentURL.replacingOccurrences(of: ".json", with: "")
        }
        currentURL.append("/\(name).json")
        return self
    }
    
    func makeRequest(urlString: String, method: HTTPMethod = .get, header: [String: Any]?) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            assert(true, "url failed")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        switch method {
        case .get:
            return request
        case .post:
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["Content-Type"] = "application/json"
            request.allHTTPHeaderFields = headers
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        default:
            return nil
        }
        
    }
    
    func fetchData<T: Decodable>(by decodeType: T.Type, _ completion: @escaping (Result<T>, URLResponse?)->()) {
        guard let request = makeRequest(urlString: currentURL, header: nil) else {
            assert(true, "request build failed")
            return
        }
        currentURL = baseURL // 사용후 URL 초기화
        fetch(with: request, decodeType: decodeType) { (result, response) in
            switch result {
            case .success(let data):
                completion(.success(data), response)
                
            case.failure(let error):
                completion(.failure(error), response)
            }
        }
    }
    
    //POST 로 데이터베이스에 보내는 방식. UID 가 자동으로 하나 생성되게 된다
    func setData<T: Encodable>(data: T, _ completion: @escaping (Result<Bool>, URLResponse?)->()) {
        if var request = makeRequest(urlString: currentURL, method: .post, header: nil) {
            do {
                request.httpBody = try JSONEncoder().encode(data)
            } catch(_) {
                assert(true, APIError.jsonParsingFailure.localizedDescription)
            }
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error), response)
                    return
                }
                completion(.success(true), response)
            }
            task.resume()
        } else {
            assert(true, "request failed")
            return
        }
    }
    
    
}
