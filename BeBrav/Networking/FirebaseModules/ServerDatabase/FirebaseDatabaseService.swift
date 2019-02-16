//
//  FirebaseDatabaseService.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol FirebaseDatabaseService: FirebaseService {
    
    func write<T: Encodable>(path: String,
                             data: T,
                             method: HTTPMethod,
                             completion: @escaping (Result<Data>, URLResponse?) -> Void)
    
    func read<T : Decodable>(path: String,
                             type: T.Type,
                             queries: [URLQueryItem]?,
                             completion: @escaping (Result<T>, URLResponse?) -> Void)
    
    func delete(path: String,
                completion: @escaping (Result<URLResponse?>) -> Void)
}
