//
//  DatabaseHandlerError.swift
//  BeBrav
//
//  Created by Seonghun Kim on 20/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

// MARK:- Database Error
enum DatabaseError: Error {
    case openDatabase
    case accessTable
    case accessData
    case saveData
    case fetchData
}

// MARK:- CustomNSError Protocol
extension DatabaseError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .openDatabase:
            return 300
        case .accessTable:
            return 301
        case .accessData:
            return 302
        case .saveData:
            return 303
        case .fetchData:
            return 304
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case .openDatabase:
            return ["File": #file, "Type":"openDatabase", "Message":"No Database at DatabaseHandler"]
        case .accessTable:
            return ["File": #file, "Type":"accessTable", "Message":"Failure access table"]
        case .accessData:
            return ["File": #file, "Type":"accessData", "Message":"Failure access data"]
        case .saveData:
            return ["File": #file, "Type":"save", "Message":"Failure save data"]
        case .fetchData:
            return ["File": #file, "Type":"fetch", "Message":"Failure fetch data"]
        }
    }
}
