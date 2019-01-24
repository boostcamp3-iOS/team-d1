//
//  EndPoint.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct EndPoint {
    
    static let dataBaseBaseURL = "https://bravyprototype.firebaseio.com"
    static let storageBaseURL = "https://firebasestorage.googleapis.com/v0/b/bravyprototype.appspot.com/o"
}

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}
