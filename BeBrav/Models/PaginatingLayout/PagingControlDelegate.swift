//
//  PagingControlDelegate.swift
//  BeBrav
//
//  Created by bumslap on 13/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol PagingControlDelegate: class {
    func constructNextLayout(indexList: [Int], pageSize: Int)
}
