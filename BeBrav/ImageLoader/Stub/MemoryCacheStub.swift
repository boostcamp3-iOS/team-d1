
//
//  MemoryCache.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MemoryCacheStub: MemoryCacheProtocol {
    func fetchImage(url: URL) -> UIImage? {
        return UIImage()
    }
    
    func setImage(image: UIImage, url: URL) {
        return
    }
}
