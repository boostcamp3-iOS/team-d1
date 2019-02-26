//
//  URLSessionTaskProtocol.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol URLResponseProtocol {
    
    var isSuccess: Bool { get }
    
    var url: URL? { get }
    
    func isMimeType(type: MimeType) -> Bool
    
    
}

extension URLResponse: URLResponseProtocol {
    
}
