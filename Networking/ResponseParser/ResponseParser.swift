//
//  ResponseParser.swift
//  BeBrav
//
//  Created by bumslap on 31/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// ResponseParser은 response 자체의 유효성을 테스트하고 서버응답을 통해서 받은 Json 데이터를 파싱하는
/// 프로토콜입니다.

import Foundation

protocol ResponseParser {

    func parseResponse(response: URLResponse?,
                       mimeType: MimeType) -> URLResponse
    
    func extractDecodedJsonData<T: Decodable>(decodeType: T.Type,
                                              binaryData: Data?) -> T?
    
    func extractEncodedJsonData<T: Encodable>(data: T) -> Data?
}
