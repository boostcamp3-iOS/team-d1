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
        } else {
            return "No error message at SQLite Database"
        }
    }
    
    // MARK:- initialize
    init(database: OpaquePointer?) {
        self.database = database
    }
    
    deinit {
        sqlite3_close(database)
    }
    
    // MARK:- Open SQLite Wrapper
    static func Open(fileManager: FileManagerProtocol) throws -> SQLiteDatabase {
        var database: OpaquePointer?
        
        let fileURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("BeBravDatabase.sqlite")
        
        if sqlite3_open(fileURL?.path, &database) != SQLITE_OK {
            defer {
                if database != nil { sqlite3_close(database) }
            }
            
            let error = String(cString: sqlite3_errmsg(database))
            assertionFailure(error)
            throw SQLiteError.OpenDatabase(message: "Failure Open SQLite Database")
        }
        
        return SQLiteDatabase(database: database)
    }
    
    // MARK:- Prepare SQL Query statement
    private func prepare(query: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
    // MARK:- Create table at SQLite Database
    public func createTable(name: String, column: [String]) -> Bool {
        let column = column.reduce("") { $0 + ", \(idFieldName(name: $1)) \(STRING)"}
        let query = "\(CREATE) \(TABLE) \(IF) \(NOT) \(EXISTS) \(name) (primaryKey \(INT) PRIMARY KEY AUTOINCREMENT\(column.count > 0 ? column : ""));"
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
            assertionFailure("Failure create table : \(errorMessage)")
            return false
        }
        
        print("Successfully created table \(name)")
        
        return true
    }
    
    // MARK:- Insert rows at table in SQLite Database
    public func insert(table: String, rows: [String: String]) throws -> Bool {
        var field = ""
        var valueCount = ""
        let column = rows.enumerated().map { (index, column) -> String in
            field += "\(index != 0 ? ", " : "")\(column.key)"
            valueCount += "\(index != 0 ? ", ?" : "?")"
            return column.value
        }
        let query = "\(INSERT) \(INTO) \(table) (\(field)) \(VALUES) (\(valueCount));"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        for (i, v) in column.enumerated() {
            let index = Int32(i + 1)
            let text = v.trimmingCharacters(in: .whitespacesAndNewlines)
            if sqlite3_bind_text(statement, index, text, -1, nil) != SQLITE_OK {
                throw SQLiteError.Bind(message: errorMessage)
            }
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully inserted value at \(table)")
        
        return true
    }
    
    // MARK:- Fetch column at table in SQLite Database
    public func fetch(table: String, column: String? = nil, idField: String = "", idRow: String = "") throws -> [[String: String]] {
        let id = idFieldName(name: idField)
        let column = column != nil ? idFieldName(name: id) : "*"
        
        var query = "\(SELECT) \(column) \(FROM) \(table)"
        var values: [[String: String]] = []
        
        if !id.isEmpty && !idRow.isEmpty {
            query.append(" \(WHERE) \(id) = \(idRow)")
        }
        
        query += ";"
        
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
    public func update(table: String, column: String, row: String, idField: String, idRow: String) throws {
        let query = "\(UPDATE) \(table) \(SET) \(column) = '\(row)' \(WHERE) \(idField) = '\(idRow)';"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully updated value at \(table) with \(idField)/\(column):\(row)")
    }
    
    // MARK:- Delete row at table in SQLite Database
    public func delete(table: String, idField: String, idRow: String) throws {
        let query = "\(DELETE) \(FROM) \(table) \(WHERE) \(idField) = \(idRow);"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
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

// MARK:- SQLite Error
fileprivate enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

// MARK:- Query
fileprivate let CREATE = "CREATE"
fileprivate let SELECT = "SELECT"
fileprivate let INSERT = "INSERT"
fileprivate let UPDATE = "UPDATE"
fileprivate let DELETE = "DELETE"

fileprivate let FROM = "FROM"
fileprivate let INTO = "INTO"
fileprivate let SET = "SET"
fileprivate let WHERE = "WHERE"
fileprivate let IF = "IF"
fileprivate let NOT = "NOT"
fileprivate let EXISTS = "EXISTS"

fileprivate let TABLE = "TABLE"
fileprivate let VALUES = "VALUES"

fileprivate let INT = "INTEGER"
fileprivate let STRING = "TEXT"
