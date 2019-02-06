//
//  ModelProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 30/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol DataModelProtocol {
    
    // MARK:- Properties
    var id: String { get }
    var isEmpty: Bool { get }
    var variableList: [String: String] { get }
    var columns: [String] { get }
    var rows: [Int: String] { get }
    
    // MARK:- Initialize
    init()
    init(data: [String: String])
}
