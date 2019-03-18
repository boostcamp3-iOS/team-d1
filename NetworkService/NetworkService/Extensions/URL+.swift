//
//  URL+.swift
//  BeBrav
//
//  Created by bumslap on 01/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// asUrlWithoutEncoding은 특정 URL 인코딩 시 인식하는 부분이 달라 (%2F -> "/" 등) 인코딩 형식을
/// 제거하는 extension 입니다.

import Foundation

extension URL {
    func asUrlWithoutEncoding() -> URL? {
        guard let stringUrl = self.absoluteString.removingPercentEncoding else {
            return nil
        }
        return URL(string: stringUrl)
    }
}
