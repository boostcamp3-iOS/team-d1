//
//  FirebaseDatabaseService.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import NetworkServiceProtocols
import Sharing

public protocol FirebaseDatabaseService: FirebaseService {
    
    func write<T: Encodable>(path: String,
                             data: T,
                             method: HTTPMethod,
                             headers: [String: String],
                             completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void)
    
    func read<T : Decodable>(path: String,
                             type: T.Type,
                             headers: [String: String],
                             queries: [URLQueryItem]?,
                             completion: @escaping (Result<T>, URLResponseProtocol?) -> Void)
    
    func delete(path: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> Void)
}
