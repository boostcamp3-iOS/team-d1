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
    
    func loadImage()
}

extension MemoryCacheProtocol {
    public func loadImage() {
        return
    }
}
