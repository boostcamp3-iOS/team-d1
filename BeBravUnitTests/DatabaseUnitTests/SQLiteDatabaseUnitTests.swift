//
//  SQLiteDatabaseUnitTests.swift
//  BeBravUnitTests
//
//  Created by Seonghun Kim on 22/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import XCTest
@testable import BeBrav
class SQLiteDatabaseUnitTests: XCTestCase {
    
    let databaseName = "TestDatabase"
    let tableName = "TestTable"
    let column = "TestField"
    let row = "TestRows"
    
    let fileManager = FileManager.default
    var database: SQLiteDatabaseProtocol = SQLiteDatabaseStub()

    override func setUp() {
        let sqlite = try? SQLiteDatabase.open(name: databaseName, fileManager: fileManager)
        database = sqlite ?? SQLiteDatabaseStub()
        _ = database.createTable(name: tableName, columns: [column])
    }

    override func tearDown() {
        guard let fileURL = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ).appendingPathComponent("\(databaseName).sqlite")
            else
        {
            return
        }
        
        try? fileManager.removeItem(at: fileURL)
        database = SQLiteDatabaseStub()
    }
    
    func testOpenDatabase() {
        let database = try? SQLiteDatabase.open(name: databaseName, fileManager: fileManager)
        XCTAssertNotNil(database, "Failure open SQLite Database")
    }
    
    func testCreateTable() {
        let database = try? SQLiteDatabase.open(name: databaseName, fileManager: fileManager)
        
        let createTable: Bool = database?.createTable(name: tableName, columns: [column]) ?? false
        
        XCTAssert(createTable, "Failure create \(tableName) table to SQLite Database")
    }
    
    func testInsert() {
        do {
            let insert = try database.insert(table: tableName, columns: [column], rows: [0: row])
            
            XCTAssert(insert, "Failure insert data to SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testFetch() {
        do {
            let _ = try database.fetch(table: tableName, column: column, idField: column, idRow: row, condition: nil)
            
            XCTAssert(true, "Failure fetch data from SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testDelete() {
        do {
            try database.delete(table: tableName, idField: column, idRow: row)
            
            XCTAssert(true, "Failure delete data from SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testUpdate() {
        do {
            try database.update(table: tableName, column: column, row: row, idField: column, idRow: row)
            
            XCTAssert(true, "Failure delete data from SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testInsertData() {
        let row = "testInsertData"
        
        do {
            guard try database.insert(table: tableName, columns: [column], rows: [0: row]) else {
                XCTAssert(false, "Failure insert data to SQLite Database")
                return
            }
            
            let data = try database.fetch(table: tableName, column: column, idField: column, idRow: row, condition: nil)
            let test = data.contains(where: { $0[column] == row })
            
            XCTAssert(test, "Failure insert data to SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testDeleteData() {
        let row = "testDeleteData"
        
        do {
            guard try database.insert(table: tableName, columns: [column], rows: [0: row]) else {
                XCTAssert(false, "Failure insert data to SQLite Database")
                return
            }
            
            try database.delete(table: tableName, idField: column, idRow: row)
            
            let data = try database.fetch(table: tableName, column: column, idField: column, idRow: row, condition: nil)
            let test = data.contains(where: { $0[column] == row })
            
            XCTAssertFalse(test, "Failure delete data from SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testUpdateData() {
        let row = "testUpdateData"
        let updateRow = "testUpdateDataUpdateRow"
        
        do {
            guard try database.insert(table: tableName, columns: [column], rows: [0: row]) else {
                XCTAssert(false, "Failure insert data to SQLite Database")
                return
            }
            
            try database.update(table: tableName, column: column, row: updateRow, idField: column, idRow: row)
            
            let data = try database.fetch(table: tableName, column: column, idField: column, idRow: updateRow, condition: nil)
            
            let preDataContains = data.contains(where: { $0[column] == row })
            let dataContains = data.contains(where: { $0[column] == updateRow })

            XCTAssert(!preDataContains && dataContains, "Failure update data to SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testFetchData() {
        let row = "testFetchData"
        
        do {
            let deletedData = try database.fetch(table: tableName, column: column, idField: column, idRow: row, condition: nil)
            
            if deletedData.contains(where: { $0[column] == row }) {
                XCTAssert(false, "Failure fetch data from SQLite Database")
            }

            guard try database.insert(table: tableName, columns: [column], rows: [0: row]) else {
                XCTAssert(false, "Failure insert data to SQLite Database")
                return
            }
            
            let data = try database.fetch(table: tableName, column: column, idField: column, idRow: row, condition: nil)
            let fetched = data.contains(where: { $0[column] == row })
            
            XCTAssert(fetched, "Failure fetch data from SQLite Database")
        } catch let error {
            XCTAssert(false, error.localizedDescription)
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
