//
//  EndPoint.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

public class FirebaseEndPoint {
    
    private init(){}
    static let shared = FirebaseEndPoint()
    let dataBaseBaseURL = "https://bravyprototype.firebaseio.com"
    let storageBaseURL = "https://firebasestorage.googleapis.com"
    let authBaseURL = "https://www.googleapis.com"
    let appKey = "AIzaSyAYybIIekNduWeVeHIQhcgW9M4TmVuwGn0"
}

public enum FirebaseDatabase: String {
    case reference
    
    public var urlComponents: URLComponents? {
        guard let components = URLComponents(string: FirebaseEndPoint.shared.dataBaseBaseURL) else {
            return nil
        }
        return components
    }
}

public enum FirebaseAuth: String {
    case auth
    
    public var urlComponents: URLComponents? {
        guard var components = URLComponents(string: FirebaseEndPoint.shared.authBaseURL) else {
            return nil
        }
        components.path = "/identitytoolkit/v3/relyingparty"
        components.queryItems = [URLQueryItem(name: "key", value: FirebaseEndPoint.shared.appKey)]
        return components
    }
}

public enum FirebaseStorage: String {
    case storage

    public var urlComponents: URLComponents? {
        guard var components = URLComponents(string: FirebaseEndPoint.shared.storageBaseURL) else {
            return nil
        }
        components.path = "/v0/b/bravyprototype.appspot.com/o"
        components.queryItems = [URLQueryItem(name: "alt", value: "media")]
        return components
    }
}

