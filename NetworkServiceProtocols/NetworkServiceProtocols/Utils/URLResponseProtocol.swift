//
//  URLSessionTaskProtocol.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import Sharing

public protocol URLResponseProtocol {
    var isSuccess: Bool { get }
    func isMimeType(type: MimeType) -> Bool
    var url: URL? { get }
    
}

extension URLResponse {
    
    public var isSuccess: Bool {
        guard let response = self as? HTTPURLResponse else { return false }
        return (200...299).contains(response.statusCode)
    }
    
    public func isMimeType(type: MimeType) -> Bool {
        guard let mimeType = self.mimeType, mimeType == type.rawValue else {
            return false
        }
        return true
    }
}

extension URLResponse: URLResponseProtocol {

}
