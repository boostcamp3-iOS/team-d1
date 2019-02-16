//
//  ImageLoaderError.swift
//  BeBrav
//
//  Created by Seonghun Kim on 14/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

// MARK:- FileManager Error
enum DiskCacheError: Error {
    case createFolder
    case fileName
    case saveData
    case deleteData
}

extension DiskCacheError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabaseError"
    
    var errorCode: Int {
        switch self {
        case .createFolder:
            return 200
        case .fileName:
            return 201
        case .saveData:
            return 202
        case .deleteData:
            return 203
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case .createFolder:
            return ["Type":"createFolder", "Message":"Failure access document directory"]
        case .fileName:
            return ["Type":"fileName", "Message":"Failure to create file name from URL"]
        case .saveData:
            return ["Type":"save", "Message":"Failure create image file"]
        case .deleteData:
            return ["Type":"delete", "Message":"Failure exists file for delete"]
        }
    }
}
