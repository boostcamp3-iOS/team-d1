//
//  ImageCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ImageLoader: DiskCacheProtocol, MemoryCacheProtocol {

    static let shared = ImageLoader()
    
    public let fileManager: FileManagerProtocol
    public let folderName = "ArtworkImage"
    
    public var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 10
        return cache
    }()

    init(fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
    }
    
    convenience init() {
        self.init(fileManager: FileManager.default)
    }
    
    func a() {
//        try saveImage(image: <#T##UIImage#>, name: <#T##String#>)
//        try fetchImage(name: <#T##String#>)
    }
}
