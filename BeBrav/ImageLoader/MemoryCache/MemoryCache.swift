//
//  MemoryCache.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MemoryCache: MemoryCacheProtocol {
    // MARK:- Singleton
    static let shared = MemoryCache()
    
    // MARK:- Properties
    private var cache: NSCache<NSString, ImageData> = {
        let cache = NSCache<NSString, ImageData>()
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()
    
    // MARK:- Fetch image from cache
    final func fetchImage(url: URL) -> UIImage? {
        let key: NSString = url.absoluteString as NSString
        let imageData = cache.object(forKey: key)
        return UIImage(data: imageData?.data ?? Data())
    }
    
    // MARK:- Set image to cache
    final func setImage(data: Data, url: URL) {
        let key: NSString = url.absoluteString as NSString
        let size = data.count
        let imageData = ImageData(data: data)
        
        cache.setObject(imageData, forKey: key, cost: size)
    }
}
