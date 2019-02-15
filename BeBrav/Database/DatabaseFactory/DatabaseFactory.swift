//
//  DatabaseFactory.swift
//  BeBrav
//
//  Created by Seonghun Kim on 13/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct DatabaseFactory {
    let databaseName = "BeBravDatabase"
    
}

extension DatabaseFactory: DatabaseFactoryProtocol {
    func buildDatabaseHandler() -> DatabaseHandler {
        let databaseHandler = DatabaseHandler.shared
        let fileManager = FileManager.default
        
        databaseHandler.database = {
            let database: SQLiteDatabase?
            
            do {
                database = try SQLiteDatabase.open(
                    name: databaseName,
                    fileManager: fileManager
                )
            } catch let error {
                database = nil
                assertionFailure(error.localizedDescription)
            }
            
            return database
        }()
        
        return databaseHandler
    }
}

