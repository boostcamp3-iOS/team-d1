//
//  EndPoint.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

public var dataBaseBaseURL: String {
    return "https://bravyprototype.firebaseio.com"
}

public var storageBaseURL: String {
    return "https://firebasestorage.googleapis.com/v0/b/bravyprototype.appspot.com/o"
}

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}



