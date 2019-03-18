//
//  FirebaseServerService.swift
//  FirebaseModuleProtocols
//
//  Created by bumslap on 17/03/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import NetworkServiceProtocols
import Sharing

public protocol FirebaseServerService {
    func signUp(email: String,
                       password: String,
                       completion: @escaping (Result<URLResponseProtocol?>) -> ())
    
    func signIn(email: String,
                       password: String,
                       completion: @escaping (Result<URLResponseProtocol?>) -> ())
    
    func uploadArtwork(image: UIImage,
                              scale: CGFloat,
                              path: String,
                              fileName: String,
                              completion: @escaping (Result<URLResponseProtocol?>)->())

}
