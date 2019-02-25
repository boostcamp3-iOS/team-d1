//
//  FirebaseAuthService.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol FirebaseAuthService: FirebaseService {
    
    func signUp(email: String,
                password: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> ())
    
    func signIn(email: String,
                password: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> ())
}
