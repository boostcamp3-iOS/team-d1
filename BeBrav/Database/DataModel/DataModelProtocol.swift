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
    var tableName: String { get }
    var variableList: [String: String] { get }
    var columns: [String] { get }
    var rows: [Int: String] { get }
    
    // MARK:- Set Data
    func setData(data: [String: String]) -> DataModelProtocol
    
    // MARK:- is Equal
    func isEqual(model: DataModelProtocol) -> Bool
    
    // MARK:- Initialize
    init()
    init(data: [String: String])
}

