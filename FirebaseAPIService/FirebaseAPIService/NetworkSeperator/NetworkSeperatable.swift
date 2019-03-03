//
//  Dispatchable.swift
//  BeBrav
//
//  Created by bumslap on 02/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//


/// NetworkSeperatable은 다양한 HTTPMethod을 3개의 메서드로 추상화 하여 구분하는 프로토콜입니다.

import Foundation

protocol NetworkSeperatable {
    
    func read(path: String,
              headers: [String: String],
              queries: [URLQueryItem]?,
              completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void)
    
    func write(path: String,
               data: Data,
               method: HTTPMethod,
               headers: [String: String],
               queries: [URLQueryItem]?,
               completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void)
    
    func delete(path: String,
                completion: @escaping (Result<Data>, URLResponseProtocol?) -> Void)
    
    
}
