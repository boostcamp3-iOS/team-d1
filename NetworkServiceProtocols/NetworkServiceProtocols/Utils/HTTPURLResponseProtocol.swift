//
//  HTTPURLResponseProtocol.swift
//  BeBrav
//
//  Created by bumslap on 25/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol HTTPURLResponseProtocol: URLResponseProtocol {
    
    var statusCode: Int { get }
    
}

extension HTTPURLResponse: HTTPURLResponseProtocol {
    
}
