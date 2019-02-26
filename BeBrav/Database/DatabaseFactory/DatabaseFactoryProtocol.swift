//
//  DatabaseFactoryProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 13/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol DatabaseFactoryProtocol {
    func buildDatabaseHandler() -> DatabaseHandler
}
