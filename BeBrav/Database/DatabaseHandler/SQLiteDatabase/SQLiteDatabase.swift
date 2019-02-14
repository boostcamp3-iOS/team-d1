//
//  SQLiteDatabase.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteDatabase: SQLiteDatabaseProtocol {
    
    // MARK:- Properties
    private var database: OpaquePointer?
    private var errorMessage: String {
        if let error = sqlite3_errmsg(database) {
            return String(cString: error)
        }
        return "No error message at SQLite Database"
    }
    
    // MARK:- initialize
    init(database: OpaquePointer?) {
        self.database = database
    }
    
    deinit {
        sqlite3_close(database)
    }
    
    // MARK:- Open SQLite Wrapper
    static func open(name: String, fileManager: FileManagerProtocol)
        throws -> SQLiteDatabase
    {
        var database: OpaquePointer?
        
        let fileURL = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
            ).appendingPathComponent("\(name).sqlite")
        
        if sqlite3_open(fileURL?.path, &database) != SQLITE_OK {
            defer {
                if database != nil { sqlite3_close(database) }
            }
            
            let error = String(cString: sqlite3_errmsg(database))
            assertionFailure(error)
            throw SQLiteError.openDatabase(message: error)
        }
        
        return SQLiteDatabase(database: database)
    }
    
    // MARK:- Prepare SQL Query statement
    private func prepare(query: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
            else
        {
            throw SQLiteError.prepare(message: errorMessage)
        }
        
        return statement
    }
    
    // MARK:- Create table at SQLite Database
    final func createTable(name: String, columns: [String]) -> Bool {
        let column = columns.reduce("") { $0 + ", \(idFieldName(name: $1)) TEXT"}
        let columnString = column.count > 0 ? column : ""
        let query = """
        CREATE TABLE IF NOT EXISTS \(name)(
        primaryKey INTEGER PRIMARY KEY AUTOINCREMENT\(columnString)
        );
        """
        
        let statement: OpaquePointer?
        
        do {
            statement = try prepare(query: query)
        } catch let error {
            assertionFailure(error.localizedDescription)
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            assertionFailure(
                "Failure create table : \(errorMessage)"
            )
            return false
        }
        
        print("Successfully created table \(name)")
        
        return true
    }
    
    // MARK:- Insert rows at table in SQLite Database
    final func insert(table: String, columns: [String], rows: [Int: String])
        throws -> Bool
    {
        var field = ""
        var fieldCount = ""
        columns.enumerated().forEach{ (i, v) in
            field += "\(i != 0 ? ", " : "")\(v)"
            fieldCount += "\(i != 0 ? ", ?" : "?")"
        }
        let query = "INSERT INTO \(table) (\(field)) VALUES (\(fieldCount));"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        for i in columns.indices {
            let index = Int32(i + 1)
            let text: NSString
                = rows[i]?.trimmingCharacters(in: .whitespacesAndNewlines)
                    as NSString? ?? ""
            if sqlite3_bind_text(statement,index, text.utf8String, -1, nil)
                != SQLITE_OK
            {
                throw SQLiteError.bind(message: errorMessage)
            }
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        
        print("Successfully inserted value at \(table)")
        
        return true
    }
    
    // MARK:- Fetch column at table in SQLite Database
    public func fetch(table: String,
                      column: String? = nil,
                      idField: String = "",
                      idRow: String = "",
                      condition: Condition?)
        throws -> [[String: String]]
    {
        let id = idFieldName(name: idField)
        let column = column != nil ? idFieldName(name: id) : "*"
        
        var query = "SELECT \(column) FROM \(table)"
        var values: [[String: String]] = []
        
        if !id.isEmpty && !idRow.isEmpty {
            let condition = condition?.rawValue ?? "="
            query.append(" WHERE \(id) \(condition) \(idRow)")
        }
        
        query.append(";")
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement) == SQLITE_ROW) {
            var value: [String: String] = [:]
            for i in 0..<sqlite3_column_count(statement) {
                let name = String(cString: sqlite3_column_name(statement, i))
                let text = String(cString: sqlite3_column_text(statement, i))
                value.updateValue(text, forKey: idDataName(name: name))
            }
            values.append(value)
        }
        
        print("Successfully read value at \(table) with \(column)")
        
        return values
    }
    
    // MARK:- Update row at table in SQLite Database
    final func update(table: String,
                      column: String,
                      row: String,
                      idField: String,
                      idRow: String) throws
    {
        let query = "UPDATE \(table) SET \(column) = '\(row)' WHERE \(idField) = '\(idRow)';"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(
                message: errorMessage + " from \(#function) in \(#line)"
            )
        }
        
        print("Successfully updated value at \(table) with \(idField)/\(column):\(row)")
    }
    
    // MARK:- Delete row at table in SQLite Database
    final func delete(table: String, idField: String, idRow: String) throws {
        let query = "DELETE FROM \(table) WHERE \(idField) = '\(idRow)';"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        
        print("Successfully deleted field at \(table) with \(idField)")
    }
    
    // MARK:- Change id string
    private func idFieldName(name: String) -> String {
        return name != "primaryKey" ? name : "primaryId"
    }
    
    private func idDataName(name: String) -> String {
        return name != "primaryId" ? name : "primaryKey"
    }
}

public enum Condition: String {
    case greater = ">"
    case less = "<"
    case equal = "="
}

// MARK:- SQLite Error
fileprivate enum SQLiteError: Error {
    case openDatabase(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
}

extension SQLiteError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .openDatabase:
            return 200
        case .prepare:
            return 201
        case .step:
            return 202
        case .bind:
            return 203
        }
    }
    
    var userInfo: [String: Any] {
        switch self {
        case let .openDatabase(message):
            return ["File": #file, "Type": "openDatabase", "Message":message]
        case let .prepare(message):
            return ["File": #file, "Type": "prepare", "Message":message]
        case let .step(message):
            return ["File": #file, "Type": "step", "Message":message]
        case let .bind(message):
            return ["File": #file, "Type": "bind", "Message":message]
        }
    }
}
