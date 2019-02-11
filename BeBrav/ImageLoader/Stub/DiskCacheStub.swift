//
//  DiskCacheStub.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class DiskCacheStub: DiskCacheProtocol {
    public let fileManager: FileManagerProtocol
    public let folderName: String = "DiskCacheStub"
    public var diskCacheList: Set<String> = []
    
    init() {
        self.fileManager = FileManagerStub()
    }
}
