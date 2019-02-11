//
//  ImageCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ImageLoader {

    // MARK:- Singleton
    static let shared = ImageLoader()

    // MARK:- Properties
    public let diskCache: DiskCacheProtocol
    public let memoryCache: MemoryCacheProtocol

    // MARK:- Initialize
    init(diskCache: DiskCacheProtocol, memoryCache: MemoryCacheProtocol) {
        self.diskCache = diskCache
        self.memoryCache = memoryCache
    }
    
    convenience init() {
        self.init(
            diskCache: DiskCache(fileManager: FileManager.default),
            memoryCache: MemoryCache()
        )
    }
    
    // MARK:- Fetch cache image
    private func fetchCacheImage(url: URL) -> UIImage? {
        if let image = memoryCache.fetchImage(url: url) {
            return image
        }
        
        if let image = diskCache.fetchImage(url: url) {
            return image
        }

        return nil
    }
    
    // MARK:- Save cache image
    private func saveCacheImage(url: URL, image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.memoryCache.setImage(image: image, url: url)
        }
        
        DispatchQueue.global(qos: .utility).async {
            do  {
                try self.diskCache.saveImage(image: image, url: url)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
