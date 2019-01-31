//
//  URLResponse+.swift
//  BeBrav
//
//  Created by bumslap on 30/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

extension URLResponse {
    
    var isSuccess: Bool {
        guard let response = self as? HTTPURLResponse else { return false }
        return (200...299).contains(response.statusCode)
    }
    
    func isMimeType(type: MimeType) -> Bool {
        guard let mimeType = self.mimeType, mimeType == type.rawValue else {
            
            return false
        }
        return true
    }
}
