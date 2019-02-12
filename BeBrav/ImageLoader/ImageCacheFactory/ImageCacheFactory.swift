//
//  MemoryCacheFactory.swift
//  BeBrav
//
//  Created by Seonghun Kim on 12/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct ImageCacheFactory {
    
}

extension ImageCacheFactory: ImageCacheFactoryProtocol {
    func buildDiskCache() -> DiskCache {
        let fileManager = FileManager.default
        let diskCache = DiskCache(fileManager: fileManager)
        return diskCache
    }
    
    func buildImageLoader() -> ImageLoader {
        let session = URLSession.shared
        let memoryCache = MemoryCache()
        let diskCache = buildDiskCache()
        
        let imageLoader = ImageLoader(session: session,
                                      diskCache: diskCache,
                                      memoryCache: memoryCache)
        
        return imageLoader
    }
}
