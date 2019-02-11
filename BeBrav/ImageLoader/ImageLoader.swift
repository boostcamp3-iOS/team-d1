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
    public var diskCacheList: Set<String> = []
    
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
    
    func fetchCacheImage(url: URL) -> UIImage? {
        let key = ""

        if let image = fetchMemoryCacheImage(url: url) {
            return image
        }
        
        if let image = fetchDiskCacheImage(url: url) {
            diskCacheList.insert(key)
            
            return image
        }

        return nil
    }
    
    func saveCacheImage(url: URL, image: UIImage) {
        let key = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.setMemoryCacheImage(image: image, url: url)
        }
        
        DispatchQueue.global(qos: .utility).async {
            do  {
               self.diskCacheList.insert(key)
                try self.saveDiskCacheImage(image: image, url: url)
            } catch let error {
                self.diskCacheList.remove(key)
                print(error.localizedDescription)
            }
        }
    }
}
