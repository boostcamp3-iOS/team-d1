//
//  APIService.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol APIService {
    
    var session: URLSessionProtocol { get }
    
    func checkResponse(error: Error?, response: URLResponse?) -> Result<URLResponse>
    
    func fetch<T: Decodable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void)
    
}

extension APIService {
    
    func fetch<T: Decodable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error), nil)
                return
            case .success(let response):
                if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
                    do {
                        let apiResponse = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(apiResponse), response)
                    } catch(_ ) {
                        completion(.failure(APIError.jsonParsingFailure), nil)
                    }
                } else {
                    completion(.failure(APIError.invalidData), response)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    return
                }
            }
        }
        task.resume()
    }
    
    func checkResponse(error: Error?, response: URLResponse?) -> Result<URLResponse> {
        if let error = error {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            return .failure(error)
        }
        
        guard let localResponse = response as? HTTPURLResponse,
            (200...299).contains(localResponse.statusCode) else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                return .failure(APIError.responseUnsuccessful)
        }
        return .success(localResponse)
    }
}

