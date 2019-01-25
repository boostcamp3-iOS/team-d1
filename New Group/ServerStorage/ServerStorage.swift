//
//  ServerStorage.swift
//  BeBrav
//
//  Created by bumslap on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

import UIKit

class ServerStorage: APIService {
    
    static let shared = ServerStorage()
    
    let session: URLSession

    private var currentURL = EndPoint.storageBaseURL
    private let safetyQueue = DispatchQueue(label: "safeQueue", attributes: .concurrent)
    
    var syncUrl: String {
        get {
            return safetyQueue.sync {
                currentURL
            }
        }
        set(newValue) {
            safetyQueue.async(flags: .barrier) {
                self.currentURL = newValue
            }
        }
    }
    
    private init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    private convenience init() {
        self.init(configuration: .default)
    }
    
    func child(_ name: String) -> ServerStorage {
        assert(!name.contains("/"), "no '/' in the String")
        syncUrl = syncUrl.replacingOccurrences(of: ".json", with: "")
        syncUrl = "\(syncUrl)/\(name).json"
        return self
    }
    //리퀘스트를 만든다.
    private func makeRequest(urlString: String, method: HTTPMethod = .get, fileName: String) -> URLRequest? {
        let urlWithFileName = "\(urlString)%2F\(fileName)"
        guard let url = URL(string: urlWithFileName) else { return nil }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        components.queryItems = [URLQueryItem(name: "alt", value: "media")]
        guard let fixedUrl = components.url else { return nil }
        switch method {
        case .get:
            let request = URLRequest(url: fixedUrl)
            return request
        case .post:
            var request = URLRequest(url: fixedUrl)
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["Content-Type"] = "image/jpeg"
            headers["mode"] = "cors"
            headers["cache"] = ".default"
            request.allHTTPHeaderFields = headers
            request.httpMethod = method.rawValue
            return request
        default:
            return nil
        }
    }
    //GET 으로 스토리지에 있는 데이터의 URL 토큰을 얻어온다
    private func fetchData(fileName: String, _ completion: @escaping (Result<URLResponse?>)->()) {
        
        guard let request = makeRequest(urlString: currentURL, method: .get, fileName: fileName) else { return }
        currentURL = EndPoint.storageBaseURL
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let localResponse = response as? HTTPURLResponse,
                (200...299).contains(localResponse.statusCode) else {
                    completion(.failure(APIError.responseUnsuccessful))
                    return
            }
            completion(.success(localResponse))
        }
        task.resume()
    }
    
    //GET 으로 스토리지에 있는 데이터의 URL을 얻어온다
    /* 예시코드입니다. -> artworks라는 폴더 하위의 catmage라는 이미지의 URL 요청
     Storage.storage.child("artworks").fetchDownloadUrl(fileName: "catmage") { (result) in
     switch result {
     case .failure(let error):
     print(error.localizedDescription)
     return
     case .success(let url):
     print(url)
     }
     }
     */
    func fetchDownloadUrl(fileName: String, _ completion: @escaping (Result<URL>)->()) {
        fetchData(fileName: fileName) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                return
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
    //POST 로 스토리지에 데이터를 업로드한다
    /* 예시코드 입니다. -> artworks 하위에 catmage 이미지를 0.1 스케일로 업로드한다
     Storage.storage.child("artworks").uploadImage(image: #imageLiteral(resourceName: "cat1"), scale: 0.1, fileName: "catmage") { (result) in
     
     switch result {
     case .failure(let error):
     print(error.localizedDescription)
     return
     case .success(let response):
     print(response)
     }
     }
     */
    func uploadImage(image: UIImage, scale: CGFloat, fileName: String, _ completion: @escaping (Result<URLResponse?>)->()) {
        if var request = makeRequest(urlString: currentURL, method: .post, fileName: fileName) {
            currentURL = EndPoint.storageBaseURL
            request.httpBody = image.jpegData(compressionQuality: scale)
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let localResponse = response as? HTTPURLResponse,
                    (200...299).contains(localResponse.statusCode) else {
                        completion(.failure(APIError.responseUnsuccessful))
                        return
                }
                
                completion(.success(localResponse))
            }
            task.resume()
        } else {
            assert(true, "request failed")
            return
        }
    }
}
