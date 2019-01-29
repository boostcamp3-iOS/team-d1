
//
//  DataBase.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class ServerDataBase: APIService {    
    
    let session: URLSessionProtocol
    
    private var currentURL = EndPoint.dataBaseBaseURL
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func child(_ name: String) -> ServerDataBase {
        assert(!name.contains("/"), "no '/' in the String")
        currentURL = currentURL.replacingOccurrences(of: ".json", with: "")
        currentURL = "\(currentURL)/\(name).json"
        return self
    }
    
    private func makeRequest(urlString: String, method: HTTPMethod = .get) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            assert(true, "url failed")
            return nil
        }
        var request = URLRequest(url: url)
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
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
    func fetchData<T: Codable>(by decodeType: T.Type, _ completion: @escaping (Result<T>, URLResponse?)->()) {
        guard let request = makeRequest(urlString: currentURL) else {
            //TODO: UI 구현시 뷰에서 에러메세지 출력부 추가
            assertionFailure("request failed")
            return
        }
        currentURL = EndPoint.dataBaseBaseURL // 사용후 URL 초기화
        fetch(with: request, decodeType: decodeType) { (result, response) in
            switch result {
            case .success(let data):
                completion(.success(data), response)
                
            case.failure(let error):
                //TODO: UI 구현시 삭제
                assertionFailure("fetch failed")
                completion(.failure(error), response)
            }
        }
    }
    
    //POST 로 데이터베이스에 보내는 방식. UID 가 자동으로 하나 생성되고 데이터가 덮어씌어진다
    func setData<T: Codable>(data: T, _ completion: @escaping (Result<URLResponse?>)->()) {
        if var request = makeRequest(urlString: currentURL, method: .post) {
            currentURL = EndPoint.dataBaseBaseURL
            checkJsonDataValidation(codingType: .encoding(data)) { (result, response) in
                switch result {
                case .failure(_):
                    assertionFailure("json failed")
                case .encodingSuccess(let data):
                    request.httpBody = data
                case .decodingSuccess(_):
                    return
                }
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
    func updateData<T: Codable>(data: T, _ completion: @escaping (Result<URLResponse?>)->()) {
        if var request = makeRequest(urlString: currentURL, method: .patch) {
            currentURL = EndPoint.dataBaseBaseURL
            checkJsonDataValidation(codingType: .encoding(data)) { (result, response) in
                switch result {
                case .failure(_):
                    assertionFailure("json failed")
                case .encodingSuccess(let data):
                    request.httpBody = data
                case .decodingSuccess(_):
                    return
                }
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
        } else {
            //TODO: UI 구현시 삭제
            assertionFailure("request failed")
            return
        }
    }
    
    //deleteData와 다른 메서드 간의 의존성에 주의하세요! 비동기 상황에서 어느것이 먼저 실행될 지 모르므로 핸들러를 이용해주세요
    func deleteData(_ completion: @escaping (Result<URLResponse?>)->()) {
        guard let request = makeRequest(urlString: currentURL, method: .delete) else { return }
        currentURL = EndPoint.dataBaseBaseURL
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
