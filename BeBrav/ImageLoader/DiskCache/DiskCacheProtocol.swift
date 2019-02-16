//
//  DiskCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 01/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol DiskCacheProtocol: class {
    var fileManager: FileManagerProtocol { get }
    var folderName: String { get }

    func fetchData(url: URL) -> Data?
    func saveData(data: Data, url: URL) throws
    func deleteData(url: URL) throws
}
