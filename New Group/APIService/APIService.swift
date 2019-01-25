//
//  APIService.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol APIService {
    
    var session: URLSession { get }
    
    func fetch<T: Decodable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void)
}
/*
 다양한 JSON형식에 대응할 수 있도록 제너릭 타입으로 구현하였고 해당 프로토콜을 확장하여 기본적인 fetching 기능을 추가해놓았습니다.
 */
extension APIService {
    
    func fetch<T: Decodable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        defer {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(.failure(APIError.requestFailed), response)
                return
            }
            
            guard let localResponse = response as? HTTPURLResponse,
                (200...299).contains(localResponse.statusCode) else {
                    completion(.failure(APIError.responseUnsuccessful), response)
                    return
            }
            
            if let mimeType = localResponse.mimeType, mimeType == "application/json", let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(apiResponse), response)
                } catch(_ ) {
                    completion(.failure(APIError.jsonParsingFailure), nil)
                }
            } else {
                completion(.failure(APIError.invalidData), response)
                return
            }
        }
        task.resume()
    }
}

