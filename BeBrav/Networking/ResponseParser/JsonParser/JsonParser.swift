//
//  JsonParser.swift
//  BeBrav
//
//  Created by bumslap on 31/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// JsonParser은 ResponseParser을 구현한 구조체로서 response 자체의 유효성을 테스트하고 서버응답을 통해서 받은 Json 데이터를
/// JsonDecoder/ Encoder를 이용하여 받아온 바이너리 데이터를 파싱하는 역할을 합니다.

import Foundation

struct JsonParser: ResponseParser {
    
    func parseResponse(response: URLResponseProtocol?,
                       mimeType: MimeType) -> URLResponseProtocol {
        guard let response = response, response.isSuccess,
            response.isMimeType(type: mimeType) else {
                assertionFailure("response parsing failed")
                return URLResponse.init()
        }
        return response
    }
    
     func extractDecodedJsonData<T: Decodable>(decodeType: T.Type,
                                               binaryData: Data?) -> T? {
        guard let data = binaryData else { return nil }
        do {
            let decodeData = try JSONDecoder().decode(decodeType, from: data)
            return decodeData
        } catch(_) {
            return nil
        }
    }
    
    func extractEncodedJsonData<T: Encodable>(data: T) -> Data? {
        do {
            
            let encodeData = try JSONEncoder().encode(data)
            return encodeData
        } catch(let error) {
            print(error.localizedDescription)
            return nil
        }
    }
}

