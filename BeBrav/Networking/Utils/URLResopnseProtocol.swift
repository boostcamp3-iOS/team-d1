//
//  URLResopnseProtocol.swift
//  BeBrav
//
//  Created by bumslap on 17/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol URLResponseProtocol {
    
    var isSuccess: Bool { get }
    
    func isMimeType(type: MimeType) -> Bool
    
}

extension URLResponse: URLResponseProtocol {
    
}
