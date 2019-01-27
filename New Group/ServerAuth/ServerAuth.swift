//
//  ServerAuth.swift
//  BeBrav
//
//  Created by bumslap on 26/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class ServerAuth: APIService {
    
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 7.0
        sessionConfig.timeoutIntervalForResource = 5.0
        let session = URLSession(configuration: sessionConfig)
        self.session = session
    }
    
    private func makeRequest(url: URL?, method: HTTPMethod = .get) -> URLRequest? {
        guard let url = url else {
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
    /*
     curl 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAYybIIekNduWeVeHIQhcgW9M4TmVuwGn0' -H 'Content-Type: application/json' --data-binary ‘{“email”:”kl9151@naver.com","password”:”123456”,”returnSecureToken”:true}'
     */
    func signUpUser(email: String, password: String, _ completion: @escaping (Result<URLResponse>) -> ()) {
        let userData = AuthRequestType.SignUpAndSignIn(email: email, password: password, returnSecureToken: true)
        if var request = makeRequest(url: Auth.signUp.urlComponents.url, method: .post) {
            checkJsonDataValidation(codingType: .encoding(userData)) { (result, response) in
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
                    self.checkJsonDataValidation(codingType: .decoding(AuthResponseType.self), binaryData: data, response: response) { (result, _) in
                        
                        switch result {
                        case .failure(_):
                            assertionFailure("json failed")
                        case .encodingSuccess(_):
                            return
                        case .decodingSuccess(let data):
                            UserDefaults.standard.set(data.email, forKey: "userId")
                            UserDefaults.standard.set(data.localId, forKey: "uid")
                            completion(.success(response))
                        }
                    }
                }
            }
            task.resume()
        } else {
            assertionFailure("request failed")
            return
        }
    }
    
    /*
     curl 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=[API_KEY]' \
     -H 'Content-Type: application/json' \
     --data-binary '{"email":"[user@example.com]","password":"[PASSWORD]","returnSecureToken":true}'
     */
    func signInUser(email: String, password: String, _ completion: @escaping (Result<URLResponse>) -> ()) {
        let userData = AuthRequestType.SignUpAndSignIn(email: email, password: password, returnSecureToken: true)
        if var request = makeRequest(url: Auth.signIn.urlComponents.url, method: .post) {
            checkJsonDataValidation(codingType: .encoding(userData)) { (result, response) in
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
                    self.checkJsonDataValidation(codingType: .decoding(AuthResponseType.self), binaryData: data, response: response) { (result, _) in
                        switch result {
                        case .failure(_):
                            assertionFailure("json failed")
                        case .encodingSuccess(_):
                            return
                        case .decodingSuccess(let data):
                            UserDefaults.standard.set(data.email, forKey: "userId")
                            UserDefaults.standard.set(data.localId, forKey: "uid")
                            completion(.success(response))
                        }
                    }
                }
            }
            task.resume()
        } else {
            assertionFailure("request failed")
            return
        }
    }
}
