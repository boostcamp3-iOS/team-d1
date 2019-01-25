//
//  MockSession.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class MockSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        completionHandler(Data(), nil, nil)
        return MockDataTask()
    }
}
