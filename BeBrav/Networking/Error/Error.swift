//
//  Error.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    case urlFailure
    case waitRequest
    
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .urlFailure: return "url Failure, app is gonna be off"
        case .waitRequest: return "Request is waiting"
        }
    }
}

enum AuthError: Error {
    case emailNotFound
    case passwordInvalid
    
    var localizedDescription: String {
        switch self {
        case .emailNotFound: return "not registered email"
        case .passwordInvalid: return "user enter wrong password"
        }
    }
}

struct ErrorDecodeType: Decodable {
 
    let error: ErrorCodeType
}

struct ErrorCodeType: Decodable {
    let message: String
}
/*{
    "error": {
        "code": 400,
        "message": "MISSING_EMAIL",
        "errors": [
        {
        "message": "MISSING_EMAIL",
        "domain": "global",
        "reason": "invalid"
        }
        ]
    }
}*/
