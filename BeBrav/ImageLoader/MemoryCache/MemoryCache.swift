//
//  MemoryCache.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MemoryCache: MemoryCacheProtocol {
    static var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 100*1024*1024
        return cache
    }()
    
    // MARK
//    deinit {
//        cache.removeAllObjects()
//    }
    
    // MARK:- Fetch image from cache
    final func fetchImage(url: URL) -> UIImage? {
        let key: NSString = url.absoluteString as NSString
        
        return MemoryCache.cache.object(forKey: key)
    }
    
    // MARK:- Set image to cache
    final func setImage(image: UIImage, url: URL) {
        let key: NSString = url.absoluteString as NSString
        
        MemoryCache.cache.setObject(image, forKey: key, cost: 0)
    }
}
