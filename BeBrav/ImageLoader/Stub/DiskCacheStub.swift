//
//  DiskCacheStub.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

final class DiskCacheStub: DiskCacheProtocol {
    public let fileManager: FileManagerProtocol
    public let folderName: String = "DiskCacheStub"

    init(fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
    }
    
    func fetchData(url: URL) -> Data? {
        return Data()
    }
    
    func saveData(data: Data, url: URL) throws {
        return
    }
    
    func deleteData(url: URL) throws {
        return
    }
}
