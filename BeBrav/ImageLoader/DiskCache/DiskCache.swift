//
//  DiskCache.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class DiskCache: DiskCacheProtocol {
    public var fileManager: FileManagerProtocol
    public let folderName: String = "ArtworkImage"
    public var diskCacheList: Set<String> = []
    
    init(fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
    }
    
    convenience init() {
        self.init(fileManager: FileManager.default)
    }
}
