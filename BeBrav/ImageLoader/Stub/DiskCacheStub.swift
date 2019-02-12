//
//  DiskCacheStub.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class DiskCacheStub: DiskCacheProtocol {
    public let fileManager: FileManagerProtocol
    public let folderName: String = "DiskCacheStub"

    init(fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
    }
    
    func fetchImage(url: URL) -> UIImage? {
        return UIImage()
    }
    
    func saveImage(image: UIImage, url: URL) throws {
        return
    }
    
    func deleteImage(url: URL) throws {
        return
    }
}
