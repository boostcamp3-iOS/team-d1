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
    
    func checkJsonDataValidation<T: Codable>(codingType: JsonCodingType<T>, binaryData: Data?, response: URLResponse?, _ completion: @escaping (JsonCodingResult<Data, T>, URLResponse?) -> Void)
    
}

extension APIService {
    
    func fetch<T: Codable>(with request: URLRequest, decodeType: T.Type, completion: @escaping (Result<T>, URLResponse?) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error), nil)
                return
            case .success(let response):
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                self.checkJsonDataValidation(codingType: .decoding(decodeType), binaryData: data, response: response) { (result, response) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error), nil)
                        return
                    case .decodingSuccess(let data):
                        completion(.success(data), response)
                        return
                    case .encodingSuccess(_):
                        return
                    }
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

    func checkJsonDataValidation<T: Codable>(codingType: JsonCodingType<T>, binaryData: Data? = nil, response: URLResponse? = nil, _ completion: @escaping (JsonCodingResult<Data, T>, URLResponse?) -> Void) {
        switch codingType {
        case .decoding(let dataType):
            guard let response = response else { return }
            if let mimeType = response.mimeType, mimeType == "application/json", let data = binaryData {
                do {
                    let decodeData = try JSONDecoder().decode(dataType, from: data)
                    completion(.decodingSuccess(decodeData), response)
                } catch(_ ) {
                    completion(.failure(APIError.jsonParsingFailure), nil)
                }
            }
        case .encoding(let data):
            do {
                let encodedData = try JSONEncoder().encode(data)
                completion(.encodingSuccess(encodedData), response)
            } catch(_ ) {
                completion(.failure(APIError.jsonParsingFailure), nil)
            }
            
        }
    }
}



/*
 if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
 do {
 let apiResponse = try JSONDecoder().decode(T.self, from: data)
 completion(.success(apiResponse), response)
 } catch(_ ) {
 completion(.failure(APIError.jsonParsingFailure), nil)
 }
 
 }else {
 completion(.failure(APIError.invalidData), response)
 DispatchQueue.main.async {
 UIApplication.shared.isNetworkActivityIndicatorVisible = false
 }
 return
 }*/
