//
//  String+.swift
//  BeBrav
//
//  Created by Seonghun Kim on 14/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

