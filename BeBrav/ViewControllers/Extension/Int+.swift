//
//  Int+.swift
//  BeBrav
//
//  Created by Seonghun Kim on 15/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

extension Int {
    var decimalString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}
