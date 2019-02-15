//
//  Dispatcher.swift
//  BeBrav
//
//  Created by bumslap on 02/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// Dispatcher는 Dispatchable을 실제 구현한 구조체로 request를 기반으로
/// task를 생성하고 이를 resume() 하는 역할을 맡고있습니다.

import UIKit

struct Dispatcher: Dispatchable {
    
    var baseUrl: URL?
    var session: URLSessionProtocol
    
    init(baseUrl: URL?, session: URLSessionProtocol) {
        self.baseUrl = baseUrl
        self.session = session
    }
    
    
    /// 실제 네트워크 통신을 시작하는 메서드입니다.
    ///
    /// - Parameters:
    ///   - request: dataTask() 메서드의 인자로 들어갈 URLRequest를 인자로 받습니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 값을 감싸서 연관 값으로 전달합니다.
    ///            Result<Data>, URLResponse? 로 전달되는 이유는 어떤 데이터는 HTTPHeader에
    ///            또 어떤 데이터는 body에만 전달되는 경우가 있기 때문입니다.
    func dispatch(request: URLRequest,
                  completion: @escaping (Result<Data>, URLResponse?) -> ()) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            if let error = error {
                completion(.failure(error), nil)
                return
            }
            guard response?.isSuccess ?? false else {
                completion(.failure(APIError.responseUnsuccessful), nil)
                return
            }
            guard let data = data else {
                completion(.failure(APIError.invalidData), nil)
                return
            }
            completion(.success(data), response)
        }
        task.resume()
    }
}
