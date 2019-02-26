//
//  DatabaseFactory.swift
//  BeBrav
//
//  Created by Seonghun Kim on 13/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct DatabaseFactory {
    // MARK:- Properties
    let databaseName = "BeBravDatabase"
}

// MARK:- DatabaseFactoryProtocol
extension DatabaseFactory: DatabaseFactoryProtocol {
    func buildDatabaseHandler() -> DatabaseHandler {
        let databaseHandler = DatabaseHandler.shared
        let fileManager = FileManager.default
        
        databaseHandler.fileManager = fileManager
        
        return databaseHandler
    }
}

