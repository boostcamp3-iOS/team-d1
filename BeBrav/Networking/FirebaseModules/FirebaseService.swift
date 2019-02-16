//
//  FirebaseService.swift
//  BeBrav
//
//  Created by bumslap on 02/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// FirebaseService는 Firebase와 통신하는 구조체들이 채택해야하는 프로토콜입니다.

import Foundation

protocol FirebaseService {
    
    var parser: ResponseParser { get }
    var seperator: NetworkSeperatable { get }
    
    init(seperator: NetworkSeperatable, parser: ResponseParser)
}
