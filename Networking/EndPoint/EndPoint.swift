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
    static let authBaseURL = "https://www.googleapis.com"
    static let appKey = "AIzaSyAYybIIekNduWeVeHIQhcgW9M4TmVuwGn0"
}

enum Auth: String {
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
    
    var urlComponents: URLComponents {
        if var components = URLComponents(string: EndPoint.authBaseURL) {
            components.path = path
            components.queryItems = [URLQueryItem(name: "key", value: EndPoint.appKey)]
            return components
        } else {
            fatalError("can't make Components")
        }
    }
}
/*
 curl 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAYybIIekNduWeVeHIQhcgW9M4TmVuwGn0' -H 'Content-Type: application/json' --data-binary ‘{“email”:”kl9151@naver.com","password”:”123456”,”returnSecureToken”:true}'
 */
enum Result<Value> {
    case success(Value)
    case failure(Error)
}
