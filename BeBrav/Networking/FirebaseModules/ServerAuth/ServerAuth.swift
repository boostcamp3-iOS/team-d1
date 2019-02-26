//
//  ServerAuth.swift
//  BeBrav
//
//  Created by bumslap on 26/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// ServerAuthManager는 initializer로 ResponseParser, NetworkSeparator를 받아서
/// 파이어베이스와 Authentication 관련 통신을 하는 구조체입니다. POST HTTPMethod를
/// 이용하여 로그인 / 회원가입을 담당합니다.
///
/// * NetworkSeperatable 는 공통적으로 사용하는  GET / POST / PATCH / PUT / DELETE 에 관한 메서드 방식을
/// 정의하는 프로토콜입니다. 초기화 시에는 이 프로토콜을 채택한 NetworkSeperator 구조체의 인스탠스를 인자로
/// 전달해야 합니다.
///
/// * ResponseParser 는 response의 유효성을 검증하고 JSON Parsing을 담당하는 프로토콜이며
/// 초기화 시에는 이 프로토콜을 채택한 JsonParser 구조체의 인스탠스를 인자로 전달해야 합니다.


import Foundation

struct ServerAuth: FirebaseAuthService {
    
    let parser: ResponseParser
    let seperator: NetworkSeperatable

    init(seperator: NetworkSeperatable, parser: ResponseParser) {
        self.seperator = seperator
        self.parser = parser
    }
    
    /// POST 메서드를 통해서 파이어베이스 Authentication에 접근합니다.
    ///
    /// - Parameters:
    ///   - email: 유저가 가입할 이메일 주소입니다.
    ///   - password: 유저가 가입할 비밀번호 입니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 값을 감싸서 연관 값으로 전달합니다.
    func signUp(email: String,
                password: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> ()) {
        let userData = AuthRequestType.SignUpAndSignIn(email: email,
                                                       password: password,
                                                       returnSecureToken: true)
        guard let extractedData = parser.extractEncodedJsonData(data: userData)
            else {
            completion(.failure(APIError.jsonParsingFailure))
            return
            }
        seperator.write(path: "signupNewUser",
                        data: extractedData,
                        method: .post,
                        headers: ["Content-Type": MimeType.json.rawValue])
        { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let extractedData =
                    self.parser.extractDecodedJsonData(decodeType: FirebaseAuthResponseType.self,
                                                   binaryData: data)
                else {
                    completion(.failure(APIError.jsonParsingFailure))
                    return
                }
                
                UserDefaults.standard.set(extractedData.email, forKey: "userId")
                UserDefaults.standard.set(extractedData.localId, forKey: "uid")
                UserDefaults.standard.synchronize()
                completion(.success(response))
            }
        }
    }
    
    
    /// POST 메서드를 통해서 파이어베이스 Authentication에 접근합니다.
    ///
    /// - Parameters:
    ///   - email: 유저가 로그인 할 이메일 주소입니다.
    ///   - password: 유저가 로그인 할 비밀번호 입니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 값을 감싸서 연관 값으로 전달합니다.
    ///            로그인의 경우 성공시에 유저의 UID 정보를 UserDefault에 저장합니다
    func signIn(email: String,
                password: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> ()) {
        let userData = AuthRequestType.SignUpAndSignIn(email: email,
                                                       password: password,
                                                       returnSecureToken: true)
        guard let extractedData = parser.extractEncodedJsonData(data: userData)
            else {
                completion(.failure(APIError.jsonParsingFailure))
                return
            }
        seperator.write(path: "verifyPassword",
                        data: extractedData,
                        method: .post,
                        headers: ["Content-Type": MimeType.json.rawValue])
        { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let extractedData =
                    self.parser.extractDecodedJsonData(decodeType: FirebaseAuthResponseType.self,
                                                       binaryData: data)
                    else {
                        completion(.failure(APIError.jsonParsingFailure))
                        return
                }
              
                UserDefaults.standard.set(extractedData.email, forKey: "userId")
                UserDefaults.standard.set(extractedData.localId, forKey: "uid")
                UserDefaults.standard.synchronize()
                completion(.success(response))
            }
        }
    }
}

