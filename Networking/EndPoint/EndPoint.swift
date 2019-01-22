//
//  EndPoint.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
public enum MovieApi {
    case users
}

extension MovieApi {
    var baseURL: URL {
        guard let url = URL(string: "https://bravyprototype.firebaseio.com/") else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
}

