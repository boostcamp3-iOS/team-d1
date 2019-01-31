//
//  MockDatabase.swift
//  BeBrav
//
//  Created by Seonghun Kim on 29/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class SQLiteDatabaseStub: SQLiteDatabaseProtocol {
    
    func createTable(name: String, column: [String]) -> Bool {
        return true
    }
    
    func insert(table: String, rows: [String : String]) throws -> Bool {
        return true
    }
    
    func fetch(table: String, column: String? = nil, idField: String, idRow: String) throws -> [[String : String]] {
        return []
    }
    
    func update(table: String, column: String, row: String, idField: String, idRow: String) throws {
        return
    }
    
    func delete(table: String, idField: String, idRow: String) throws {
        return
    }
}
