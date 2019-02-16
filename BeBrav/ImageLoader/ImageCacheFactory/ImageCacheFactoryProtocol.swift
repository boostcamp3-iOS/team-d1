//
//  ImageCacheFactoryProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 12/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

protocol ImageCacheFactoryProtocol {
    func buildDiskCache() -> DiskCache
    func buildImageLoader() -> ImageLoader
}
