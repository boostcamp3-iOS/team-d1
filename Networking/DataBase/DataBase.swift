//
//  DataBase.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class DataBase: APIService {

    let session: URLSession
    static let dataBase = DataBase()
    private var currentURL: String = dataBaseBaseURL
    
    private init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    private convenience init() {
        let sessionConfig = URLSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 7.0
        sessionConfig.timeoutIntervalForResource = 5.0
        self.init(configuration: sessionConfig)
    }
    
    func child(_ name: String) -> DataBase {
        assert(!name.contains("/"), "no '/' in the String")
        currentURL = currentURL.replacingOccurrences(of: ".json", with: "")
        currentURL.append("/\(name).json")
        return self
    }
    
   private func makeRequest(urlString: String, method: HTTPMethod = .get, header: [String: Any]?) -> URLRequest? {
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
        case .patch:
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
    //GET 으로 리얼타임 데이터베이스에서 데이터들을 가져오는 메서드입니다
    /* 예시코드입니다. -> root의 하위 JSON 데이터를 get으로 가져옵니다. Decodable 타입의 객체로 디코딩하기 위해서 해당 타입을 인자로 넣어줘야합니다.
     
     DataBase.dataBase.child("root").fetchData(by: Users.self) { (result, response) in
        switch result {
        case .success(let data):
            print(data)
        case .failure(let error):
            print(error.localizedDescription)
        }
     }
     */
    func fetchData<T: Decodable>(by decodeType: T.Type, _ completion: @escaping (Result<T>, URLResponse?)->()) {
        guard let request = makeRequest(urlString: currentURL, header: nil) else {
            assert(true, "request build failed")
            return
        }
        currentURL = dataBaseBaseURL // 사용후 URL 초기화
        fetch(with: request, decodeType: decodeType) { (result, response) in
            switch result {
            case .success(let data):
                completion(.success(data), response)
                
            case.failure(let error):
                completion(.failure(error), response)
            }
        }
    }
    
    //POST 로 데이터베이스에 보내는 방식. UID 가 자동으로 하나 생성되고 데이터가 덮어씌어진다
    
    func setData<T: Encodable>(data: T, _ completion: @escaping (Result<URLResponse?>)->()) {
        if var request = makeRequest(urlString: currentURL, method: .post, header: nil) {
            currentURL = dataBaseBaseURL
            do {
                request.httpBody = try JSONEncoder().encode(data)
            } catch(_) {
                assert(true, APIError.jsonParsingFailure.localizedDescription)
            }
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let localResponse = response as? HTTPURLResponse,
                    (200...299).contains(localResponse.statusCode) else {
                        completion(.failure(APIError.responseUnsuccessful))
                        return
                }
                completion(.success(localResponse))
            }
            task.resume()
        } else {
            assert(true, "request failed")
            return
        }
    }
    //UID 없이 자식으로 바로 생성
    /* 예시코드입니다. -> root의 하위 JSON 데이터를 patch로 업로드
     DataBase.dataBase.child("root").updateData(data: name) { (result, res) in
     
         switch result {
         case .success(let res):
             guard let response = res as? HTTPURLResponse else {
             return
             }
         case .failure(let error):
            print(error.localizedDescription)
         }
     }
     */
    func updateData<T: Encodable>(data: T, _ completion: @escaping (Result<URLResponse?>)->()) {
        if var request = makeRequest(urlString: currentURL, method: .patch, header: nil) {
            currentURL = dataBaseBaseURL
            do {
                request.httpBody = try JSONEncoder().encode(data)
            } catch(_) {
                assert(true, APIError.jsonParsingFailure.localizedDescription)
            }
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let localResponse = response as? HTTPURLResponse,
                    (200...299).contains(localResponse.statusCode) else {
                        completion(.failure(APIError.responseUnsuccessful))
                        return
                }
                completion(.success(localResponse))
            }
            task.resume()
        } else {
            assert(true, "request failed")
            return
        }
    }
}
