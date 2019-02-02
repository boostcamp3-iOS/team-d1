//
//  Network.swift
//  BeBrav
//
//  Created by bumslap on 31/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// Dispatchable은 baseUrl, session를 기반으로 dispatch() 메서드를 실행하여 실제 네트워킹을
/// 실행할 수 있도록 하는 프로토콜 입니다.

import UIKit

protocol Dispatchable {
    
    var baseUrl: URL?{ get }
    
    var session: URLSessionProtocol { get }
    
    func dispatch(request: URLRequest,
                    completion: @escaping (Result<Data>, URLResponse?)->())
}

