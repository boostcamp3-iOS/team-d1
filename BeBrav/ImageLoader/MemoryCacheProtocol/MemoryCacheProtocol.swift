//
//  MemoryCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 09/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol MemoryCacheProtocol {
    var cache: NSCache<NSString, UIImage> { get }
    
    func fetchMemoryCacheImage(url: URL) -> UIImage?
    func setMemoryCacheImage(key: String, image: UIImage)
}

extension MemoryCacheProtocol {
    public func fetchMemoryCacheImage(url: URL) -> UIImage? {
        let key: NSString = ""
        
        return cache.object(forKey: key)
    }
    
    public func setMemoryCacheImage(key: String, image: UIImage) {
        let key: NSString = ""
        
        cache.setObject(image, forKey: key)
    }
}
