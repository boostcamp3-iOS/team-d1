//
//  ServerAuth.swift
//  BeBrav
//
//  Created by bumslap on 26/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class ServerAuth: APIService, RequestMakable {
    
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    /*
     curl 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAYybIIekNduWeVeHIQhcgW9M4TmVuwGn0' -H 'Content-Type: application/json' --data-binary ‘{“email”:”kl9151@naver.com","password”:”123456”,”returnSecureToken”:true}'
     */
    func signUpUser(email: String, password: String, _ completion: @escaping (Result<URLResponse>) -> ()) {
        let userData = AuthRequestType.SignUpAndSignIn(email: email, password: password, returnSecureToken: true)
        guard let url = FirebaseAuth.signUp.urlComponents?.url else {
            completion(.failure(APIError.urlFailure))
            return
        }
        guard let data = extractEncodedJsonData(data: userData) else {
            completion(.failure(APIError.jsonParsingFailure))
            return
        }
        guard let request = makeRequest(string: url.absoluteString, method: .post, headers: ["Content-Type": MimeType.json.rawValue], body: data) else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                guard let data = self.extractDecodedJsonData(decodeType: AuthResponseType.self, binaryData: data) else {
                    completion(.failure(APIError.jsonParsingFailure))
                    return
                }
                UserDefaults.standard.set(data.email, forKey: "userId")
                UserDefaults.standard.set(data.localId, forKey: "uid")
                completion(.success(response))
            }
        }
        task.resume()
    }
    
    /*
     curl 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=[API_KEY]' \
     -H 'Content-Type: application/json' \
     --data-binary '{"email":"[user@example.com]","password":"[PASSWORD]","returnSecureToken":true}'
     */
    func signInUser(email: String, password: String, _ completion: @escaping (Result<URLResponse>) -> ()) {
        let userData = AuthRequestType.SignUpAndSignIn(email: email, password: password, returnSecureToken: true)
        guard let url = FirebaseAuth.signIn.urlComponents?.url else {
            completion(.failure(APIError.urlFailure))
            return
        }
        guard let data = extractEncodedJsonData(data: userData) else {
            completion(.failure(APIError.jsonParsingFailure))
            return
        }
        guard let request = makeRequest(string: url.absoluteString, method: .post, headers: ["Content-Type": MimeType.json.rawValue], body: data) else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                guard let data = self.extractDecodedJsonData(decodeType: AuthResponseType.self, binaryData: data) else {
                    completion(.failure(APIError.jsonParsingFailure))
                    return
                }
                UserDefaults.standard.set(data.email, forKey: "userId")
                UserDefaults.standard.set(data.localId, forKey: "uid")
                completion(.success(response))
            }
        }
        task.resume()
    }
}
