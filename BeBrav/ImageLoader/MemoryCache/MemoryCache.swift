//
//  MemoryCache.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MemoryCache: MemoryCacheProtocol {
    public var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 10
        return cache
    }()
    
    deinit {
        cache.removeAllObjects()
    }
}
