//
//  NetworkModel.swift
//  BeBrav
//
//  Created by bumslap on 27/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct AuthRequestType: Codable {
    struct SignUpAndSignIn: Codable {
        let email: String
        let password: String
        let returnSecureToken: Bool
    }
    enum behavior {
        case signIn
        case signUp
    }
}

enum MimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case json = "application/json"
}

struct AuthResponseType: Codable {
    let kind: String
    let idToken: String
    let email: String
    let refreshToken: String
    let expiresIn: String
    let localId: String
}

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

