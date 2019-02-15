//
//  requestBuildable.swift
//  BeBrav
//
//  Created by bumslap on 30/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// RequestMakable은 HTTP 메서드, 파라미터, 헤더, URL을 조합하여 request를 만들수 있게 하는
/// 프로토콜 입니다.

import Foundation

protocol RequestMakable {
    
    func makeRequest(url: URL?, method: HTTPMethod, headers: [String: String],
                     body: Data?) -> URLRequest?
}

