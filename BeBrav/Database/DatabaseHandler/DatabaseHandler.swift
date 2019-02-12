//
//  AccessDatabase.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

fileprivate let databaseName = "BeBravDatabase"

class DatabaseHandler {
    
    // MARK:- Singleton
    static let shared = DatabaseHandler()
    
    // MARK:- Properties
    lazy var database: SQLiteDatabaseProtocol? = try? SQLiteDatabase.open(
        name: databaseName,
        fileManager: FileManager.default
    )
    private let idField = "id"
    
    // MARk:- Initialize
    init(database: SQLiteDatabaseProtocol?) {
        self.database = database
    }
    
    convenience init() {
        let database: SQLiteDatabase?
        
        do {
            database = try SQLiteDatabase.open(
                name: databaseName,
                fileManager: FileManager.default
            )
        } catch let error {
            database = nil
            assertionFailure(error.localizedDescription)
        }
        
        self.init(database: database)
    }
    
    // MARK:- Check table is enable
    private func accessTable(data: DataModelProtocol) throws -> Bool {
        guard let database = database else {
            throw DatabaseError.openDatabase
        }
        
        return database.createTable(name: data.tableName, columns: data.columns)
    }
    
    // MARK:- Check access is enabled
    private func accessEnabled(data: DataModelProtocol) throws -> Bool {
        guard try self.accessTable(data: data) else {
            throw DatabaseError.accessTable
        }
        
        guard let list = try database?.fetch(
            table: data.tableName,
            column: idField,
            idField: idField,
            idRow: "\(data.id)",
            condition: nil
            ) else
        {
            throw DatabaseError.fetchData
        }
        
        return !list.isEmpty
    }
    
    // MARK:- Transfet data to model
    private func dataToModel(model: DataModelProtocol, data: [[String: String]])
        -> [DataModelProtocol]
    {
        return data.map{ model.setData(data: $0) }
    }
    
    // MARK:- Equal Model Filter
    private func equalFilter(model: DataModelProtocol,
                             modelArray: [DataModelProtocol])
        -> [DataModelProtocol]
    {
        return modelArray.filter{ model.isEqual(model: $0) }
    }
    
    // MARK:- Fetch Data from SQLite Database
    private func fetchData(type: DataType,
                           idField: String,
                           idRow: String,
                           condition: Condition = .equal)
        throws -> [DataModelProtocol]
    {
        let model = type.model
        
        guard try self.accessTable(data: model) else {
            throw DatabaseError.accessTable
        }
        
        guard let dataArray = try self.database?.fetch(
            table: model.tableName,
            column: nil,
            idField: idField,
            idRow: idRow,
            condition: condition
            ) else
        {
            throw DatabaseError.fetchData
        }
        
        return dataToModel(model: model, data: dataArray).filter { !$0.isEmpty }
    }
    
    // MARK:- Update Data
    private func updateData(data: DataModelProtocol) throws -> Bool {
        let id = data.id
        let table = data.tableName
        
        guard let dataArray = try self.database?.fetch(
            table: table,
            column: nil,
            idField: self.idField,
            idRow: id,
            condition: nil
            ) else
        {
            throw DatabaseError.fetchData
        }
        
        let modelList = self.dataToModel(
            model: data,
            data: dataArray
        )
        let modelArray = self.equalFilter(
            model: data,
            modelArray: modelList
        )
        
        if dataArray.count != modelArray.count || dataArray.count > 1 {
            try self.database?.delete(
                table: table,
                idField: self.idField,
                idRow: id
            )
        } else if modelArray.count == 1 {
            try data.variableList.forEach {
                try self.database?.update(
                    table: table,
                    column: $0.key,
                    row: $0.value,
                    idField: self.idField,
                    idRow: id
                )
            }
            return true
        }
        return false
    }
    
    // MARK:- Save new data or Update changed data
    public func saveData(data: DataModelProtocol,
                         completion: @escaping (Bool, Error?) -> Void = {_,_ in })
    {
        DispatchQueue.global(qos: .utility).async {
            do {
                guard try self.accessTable(data: data) else {
                    completion(false, DatabaseError.accessTable)
                    return
                }
                
                if try !self.updateData(data: data) {
                    completion(true, nil)
                    return
                }
                
                guard try self.database?.insert(
                    table: data.tableName,
                    columns: data.columns,
                    rows: data.rows
                    ) ?? false else
                {
                    completion(false, DatabaseError.saveData)
                    return
                }
                
                completion(true, nil)
            } catch let error {
                completion(false, error)
            }
        }
    }
    
    // MARK:- Delete Data
    public func deleteData(data: DataModelProtocol,
                           completion: @escaping (Bool, Error?) -> Void = {_,_ in })
    {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard try self.accessEnabled(data: data) else {
                    completion(false, DatabaseError.accessData)
                    return
                }
                
                try self.database?.delete(
                    table: data.tableName,
                    idField: self.idField,
                    idRow: String(data.id)
                )
                
                completion(true, nil)
            } catch let error {
                completion(false, error)
            }
        }
    }
    
    // MARK:- Read Data
    public func readData(type: DataType,
                         id: String,
                         completion: @escaping (DataModelProtocol?, Error?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let modelArray = try self.fetchData(
                    type: type,
                    idField: self.idField,
                    idRow: id
                )
                completion(modelArray.first, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    // MARK:- Read Author's Artwork Array
    public func readArtworkArray(author: AuthorModel,
                                 completion: @escaping ([ArtworkModel]?, Error?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let type: DataType = .ArtworkData
            let idField = "authorId"
            let idRow = author.id
            
            do {
                guard let artworkArray = try self.fetchData(
                    type: type,
                    idField: idField,
                    idRow: idRow
                    ) as? [ArtworkModel]
                    else
                {
                    completion(nil, DatabaseError.fetchData)
                    return
                }
                
                completion(artworkArray, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    // MARK:- Read Artwork Array with date
    public func readArtworkArray(keyDate: Double,
                                 condition: Condition = .equal,
                                 completion: @escaping ([DataModelProtocol]?, Error?) -> Void = {_,_ in })
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let type: DataType = .ArtworkData
            let idField = "date"
            let idRow = String(keyDate)
            
            do {
                let modelArray = try self.fetchData(
                    type: type,
                    idField: idField,
                    idRow: idRow,
                    condition: condition
                )
                completion(modelArray, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    // MARK:- Data Type Enum
    enum DataType {
        case AuthorData
        case ArtworkData
        
        var model: DataModelProtocol {
            switch self {
            case .AuthorData:
                return AuthorModel()
            case .ArtworkData:
                return ArtworkModel()
            }
        }
    }
}

// MARK:- Database Error
fileprivate enum DatabaseError: Error {
    case openDatabase
    case accessTable
    case accessData
    case saveData
    case fetchData
}

extension DatabaseError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .openDatabase:
            return 300
        case .accessTable:
            return 301
        case .accessData:
            return 302
        case .saveData:
            return 303
        case .fetchData:
            return 304
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case .openDatabase:
            return ["File": #file, "Type":"openDatabase", "Message":"No Database at DatabaseHandler"]
        case .accessTable:
            return ["File": #file, "Type":"accessTable", "Message":"Failure access table"]
        case .accessData:
            return ["File": #file, "Type":"accessData", "Message":"Failure access data"]
        case .saveData:
            return ["File": #file, "Type":"save", "Message":"Failure save data"]
        case .fetchData:
            return ["File": #file, "Type":"fetch", "Message":"Failure fetch data"]
        }
    }
}
