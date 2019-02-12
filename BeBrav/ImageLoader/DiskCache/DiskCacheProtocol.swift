//
//  DiskCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 01/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol DiskCacheProtocol: class {
    var fileManager: FileManagerProtocol { get }
    var folderName: String { get }

    func fetchImage(url: URL) -> UIImage?
    func saveImage (image: UIImage, url: URL) throws
    func deleteImage(url: URL) throws
    
    init(fileManager: FileManagerProtocol)
}
