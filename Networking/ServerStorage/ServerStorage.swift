//
//  ServerStorage.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

import UIKit

struct ServerStorage: APIService, PathMaker, RequestMakable {
    
    var pathString: String = ""
    
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }

    private func fetchData(fileName: String, _ completion: @escaping (Result<URLResponse?>)->()) {
        guard var url = FirebaseStorage.getUrl.urlComponents?.url else {
            completion(.failure(APIError.urlFailure))
            return
        }
        url.appendPathComponent("\(pathString)%2F\(fileName)")
        guard let request = makeRequest(string: url.absoluteString.removingPercentEncoding ?? "") else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(let response):
                completion(.success(response))
            }
        }
        task.resume()
    }
    
    func fetchDownloadUrl(fileName: String, _ completion: @escaping (Result<URL>)->()) {
        fetchData(fileName: fileName) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                guard let responseData = response as? HTTPURLResponse else {
                    completion(.failure(APIError.responseUnsuccessful))
                    return
                }
                guard let fetchedToken = responseData.allHeaderFields["x-goog-meta-firebasestoragedownloadtokens"] as? String else {
                    completion(.failure(APIError.invalidData))
                    return
                }
                if var urlStringFromResponse = responseData.url?.absoluteString {
                    urlStringFromResponse.append("&token=\(fetchedToken)")
                    guard let urlFromResponse = URL(string: urlStringFromResponse) else {
                        completion(.failure(APIError.responseUnsuccessful))
                        return
                    }
                    completion(.success(urlFromResponse))
                } else {
                    completion(.failure(APIError.urlFailure))
                }
            }
        }
    }

    func uploadImage(image: UIImage, scale: CGFloat, fileName: String, _ completion: @escaping (Result<URLResponse?>)->()) {
        guard var url = FirebaseStorage.getUrl.urlComponents?.url else {
            completion(.failure(APIError.urlFailure))
            return
        }
        url.appendPathComponent("\(pathString)%2F\(fileName)")
        guard let request = makeRequest(string: url.absoluteString.removingPercentEncoding ?? "", method: .post, headers:  ["Content-Type": MimeType.jpeg.rawValue, "mode": "cors"], body: image.jpegData(compressionQuality: scale)) else {
            completion(.failure(APIError.requestFailed))
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            switch self.checkResponse(error: error, response: response) {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                completion(.success(response))
            }
        }
        task.resume()
    }
}
