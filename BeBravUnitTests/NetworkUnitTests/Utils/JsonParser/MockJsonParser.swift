//
//  MockJsonParser.swift
//  BeBravUnitTests
//
//  Created by bumslap on 25/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
@testable import BeBrav

struct MockJsonParser: ResponseParser {
   
    func parseResponse(response: URLResponseProtocol?, mimeType: MimeType) -> URLResponseProtocol {
        return MockResponse()
    }
    
    func extractDecodedJsonData<T>(decodeType: T.Type, binaryData: Data?) -> T? where T : Decodable {
        return ["mock": ArtworkDecodeType(userUid: "", authorName: "", uid: "", url: "", title: "", timestamp: 0, views: 0, orientation: false, color: false, temperature: false)] as? T
    }
    
    func extractEncodedJsonData<T>(data: T) -> Data? where T : Encodable {
        return Data()
    }
    
    
}
