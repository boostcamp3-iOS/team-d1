//
//  DatabaseManager.swift
//  BeBrav
//
//  Created by bumslap on 02/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// ServerDatabase는 initializer로 ResponseParser, NetworkSeparator를 받아서
/// 파이어베이스와 실제 통신하는 구조체입니다. GET / POST / PATCH / PUT / DELETE HTTPMethod를
/// 이용하여 상황에 맞는 요청이 가능합니다. read는 기본적으로 GET을 이용하고 write는 POST / PATCH / PUT
/// 를 delete는 DELETE 메서드를 사용합니다.
///
/// * NetworkSeperatable 는 공통적으로 사용하는  GET / POST / PATCH / PUT / DELETE 에 관한 메서드 방식을
/// 정의하는 프로토콜입니다. 초기화 시에는 이 프로토콜을 채택한 NetworkSeperator 구조체의 인스탠스를 인자로
/// 전달해야 합니다.
///
/// * ResponseParser 는 response의 유효성을 검증하고 JSON Parsing을 담당하는 프로토콜이며
/// 초기화 시에는 이 프로토콜을 채택한 JsonParser 구조체의 인스탠스를 인자로 전달해야 합니다.

import Foundation
import FirebaseModuleProtocols
import NetworkServiceProtocols
import NetworkService
import Sharing

public struct ServerDatabase: FirebaseDatabaseService {
    
    public let parser: ResponseParser
    public let seperator: NetworkSeperatable
    
    public init(seperator: NetworkSeperatable, parser: ResponseParser) {
        self.seperator = seperator
        self.parser = parser
    }
    
    
    /// GET 메서드를 통해서 파이어베이스 실시간 DB에 접근하여 데이터를 가져옵니다.
    ///
    /// - Parameters:
    ///   - path: 트리로 구성된 JSON 데이터베이스에 접근하는 URL 경로입니다.
    ///   - type: 데이터를 성공적으로 가져왔을시 JSONDecoder를 이용하여 디코딩될 데이터의 타입입니다.
    ///   - queries: 데이터를 제한하여 가져오거나 특정 조건을 통해서 fetch할 수 있습니다 (구현예정)
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 값을 감싸서 연관 값으로 전달합니다.
    public func read<T : Decodable>(path: String,
                             type: T.Type,
                             headers: [String: String],
                             queries: [URLQueryItem]? = nil,
                             completion: @escaping (Result<T>, URLResponseProtocol?) -> Void) {
        seperator.read(path: "\(path).json", headers: headers, queries: queries) { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error), nil)
            case .success(let data):
                print("success")
                guard let extractedData =
                    self.parser.extractDecodedJsonData(decodeType: type,
                                                       binaryData: data) else {
                                                        completion(.failure(APIError.jsonParsingFailure), nil)
                                                        return
                }
                completion(.success(extractedData), response)
                return
            }
        }
    }
    
    
    /// POST, PATCH, PUT 메서드를 통해서 파이어베이스 실시간 DB에 접근하여 데이터를 업로드 합니다.
    /// - POST의 경우 : path로 지정한 데이터 아래 고유한 UID를 생성하고 인자로 넘겨준 데이터를 덮어쓰기 합니다.
    /// - PATCH의 경우 : path로 지정한 데이터 아래에 인자로 넘겨준 데이터를 추가합니다.
    /// - PUT의 경우 : path로 지정한 데이터 아래에 인자로 넘겨준 데이터를 UID없이 바로 덮어쓰기 합니다.
    ///
    /// - Parameters:
    ///   - path: 트리로 구성된 JSON 데이터베이스에 접근하는 URL 경로입니다.
    ///   - data: POST / PATCH / PUT 메서드를 통해서 데이터베이스로 전달할 바이너리 데이터 입니다.
    ///   - method: POST / PATCH / PUT 중 하나를 선택할 수 있습니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    ///   (GET / DELETE를 제한 하지 못하였으므로 주의하세요)
    /// - Returns: Result enum 타입으로 성공시 response를 실패시 Error 값을 감싸서 연관 값으로 전달합니다.
    public func write<T: Encodable>(path: String,
                             data: T,
                             method: HTTPMethod,
                             headers: [String: String],
                             completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void) {
        guard let extractedData =
            self.parser.extractEncodedJsonData(data: data) else {
                completion(.failure(APIError.jsonParsingFailure), nil)
                return
        }
        seperator.write(path: "\(path).json",
            data: extractedData,
            method: method,
            headers: headers) { (result, response) in
                switch result {
                case .failure(let error):
                    completion(.failure(error), nil)
                case .success(let data):
                    completion(.success(data), response)
                    return
                }
        }
    }
    
    
    /// DELETE 메서드를 통해서 파이어베이스 실시간 DB에 접근하여 데이터를 삭제합니다
    ///
    /// - Parameters:
    ///   - path: 트리로 구성된 JSON 데이터베이스에 접근하는 URL 경로입니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 값을 감싸서 연관 값으로 전달합니다
    public func delete(path: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> Void) {
        seperator.delete(path: "\(path).json") { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                completion(.success(response))
                return
            }
        }
    }
}
