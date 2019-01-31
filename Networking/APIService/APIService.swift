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
    func fetch<T: Codable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void)
    func extractEncodedJsonData<T: Encodable>(data: T) -> Data?
    func extractDecodedJsonData<T: Decodable>(decodeType: T.Type, binaryData: Data?) -> T?
}

extension APIService {
    
    func fetch<T: Decodable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                completion(.failure(error), nil)
                return
            case .success(let response):
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                guard response.isMimeType(type: .json) else {
                    completion(.failure(APIError.jsonConversionFailure), nil)
                    return
                }
                guard let extractedData = self.extractDecodedJsonData(decodeType: decodeType, binaryData: data) else {
                    completion(.failure(APIError.jsonConversionFailure), nil)
                    return
                }
                completion(.success(extractedData), nil)
                }
            }
        task.resume()
    }
    
    func checkResponse(error: Error?, response: URLResponse?) -> Result<URLResponse> {
        if let error = error {
            return .failure(error)
        }
        guard let response = response  else {
            return .failure(APIError.responseUnsuccessful)
        }
        guard response.isSuccess else {
            return .failure(APIError.responseUnsuccessful)
        }
        return .success(response)
    }
    
    func extractDecodedJsonData<T: Decodable>(decodeType: T.Type, binaryData: Data?) -> T? {
        guard let data = binaryData else { return nil }
        do {
            let decodeData = try JSONDecoder().decode(decodeType, from: data)
            return decodeData
        } catch(_ ) {
            return nil
        }
    }
    
    func extractEncodedJsonData<T: Encodable>(data: T) -> Data? {
        do {
            let encodeData = try JSONEncoder().encode(data)
            return encodeData
        } catch(_) {
            return nil
        }
    }
}

