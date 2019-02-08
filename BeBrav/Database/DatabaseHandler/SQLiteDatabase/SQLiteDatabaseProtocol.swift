//
//  SQLiteDatabaseProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 29/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol SQLiteDatabaseProtocol {
    func createTable(name: String, columns: [String]) -> Bool
    
    func insert(table: String, columns: [String], rows: [Int: String])
        throws -> Bool
    
    func fetch(table: String, column: String?,
               idField: String, idRow: String, condition: Condition?)
        throws -> [[String: String]]
    
    func update(table: String, column: String, row: String,
                idField: String, idRow: String) throws
    
    func delete(table: String, idField: String, idRow: String) throws
}
