//
//  PathMaker.swift
//  BeBrav
//
//  Created by bumslap on 30/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol PathMaker {
    
    var pathString: String { get set }
    
    mutating func addPath(_ path: String)
}

extension PathMaker {
    
    mutating func addPath(_ path: String) {
        pathString += "/\(path)"
    }
}
