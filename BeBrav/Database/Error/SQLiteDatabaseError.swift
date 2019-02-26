//
//  DatabaseError.swift
//  BeBrav
//
//  Created by Seonghun Kim on 20/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

// MARK:- SQLite Error
enum SQLiteError: Error {
    case openDatabase(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
}

// MARK:- CustomNSError Protocol
extension SQLiteError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .openDatabase:
            return 200
        case .prepare:
            return 201
        case .step:
            return 202
        case .bind:
            return 203
        }
    }
    
    var userInfo: [String: Any] {
        switch self {
        case let .openDatabase(message):
            return ["File": #file, "Type": "openDatabase", "Message":message]
        case let .prepare(message):
            return ["File": #file, "Type": "prepare", "Message":message]
        case let .step(message):
            return ["File": #file, "Type": "step", "Message":message]
        case let .bind(message):
            return ["File": #file, "Type": "bind", "Message":message]
        }
    }
}
