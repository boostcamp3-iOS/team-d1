//
//  EndPoint.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class FirebaseEndPoint {
    private init(){}
    static let shared = FirebaseEndPoint()
    let dataBaseBaseURL = "https://bravyprototype.firebaseio.com"
    let storageBaseURL = "https://firebasestorage.googleapis.com"
    let authBaseURL = "https://www.googleapis.com"
    let appKey = "AIzaSyAYybIIekNduWeVeHIQhcgW9M4TmVuwGn0"
}

enum FirebaseStorage: String {
    case upload
    case getUrl
    
    var path: String {
        switch self {
        case .upload:
            return "/v0/b/bravyprototype.appspot.com/o"
        case .getUrl:
            return "/v0/b/bravyprototype.appspot.com/o"
        }
    }
    
    var urlComponents: URLComponents? {
        if var components = URLComponents(string: FirebaseEndPoint.shared.storageBaseURL) {
            components.path = path
            components.queryItems = [URLQueryItem(name: "alt", value: "media")]
            return components
        } else {
            return nil
        }
    }
}

enum FirebaseAuth: String {
    case signUp
    case signIn
    
    var path: String {
        switch self {
        case .signUp:
            return "/identitytoolkit/v3/relyingparty/signupNewUser"
        case .signIn:
            return "/identitytoolkit/v3/relyingparty/verifyPassword"
        }
    }
    
    var urlComponents: URLComponents? {
        if var components = URLComponents(string: FirebaseEndPoint.shared.authBaseURL) {
            components.path = path
            components.queryItems = [URLQueryItem(name: "key", value: FirebaseEndPoint.shared.appKey)]
            return components
        } else {
            return nil
        }
    }
}

