//
//  NetworkModel.swift
//  BeBrav
//
//  Created by bumslap on 27/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

enum JsonCodingType<Value> {
    case encoding(Value)
    case decoding(Value.Type)
}

enum JsonCodingResult<Value, Data> {
    case encodingSuccess(Value)
    case decodingSuccess(Data)
    case failure(Error)
}

struct AuthRequestType: Codable {
    struct SignUpAndSignIn: Codable {
        let email: String
        let password: String
        let returnSecureToken: Bool
    }
}

struct AuthResponseType: Codable {
    let kind: String
    let idToken: String
    let email: String
    let refreshToken: String
    let expiresIn: String
    let localId: String
}
