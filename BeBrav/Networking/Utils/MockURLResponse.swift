//
//  MockHTTPResponse.swift
//  BeBrav
//
//  Created by bumslap on 17/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class MockURLResponse: URLResponseProtocol {
    
    var isSuccess: Bool = true
    
    func isMimeType(type: MimeType) -> Bool {
        return true
    }
    
    
}
