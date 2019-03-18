//
//  MockResponse.swift
//  BeBrav
//
//  Created by bumslap on 25/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import Sharing

class MockResponse: URLResponseProtocol {
    
    var url: URL?
    
    var statusCode: Int = 200
    
    var isSuccess: Bool {
        return self.statusCode == 200
    }
    
    func isMimeType(type: MimeType) -> Bool {
        return true
    }
    
}
