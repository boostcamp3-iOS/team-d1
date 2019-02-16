//
//  MemoryCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 09/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol MemoryCacheProtocol {
    func fetchImage(url: URL) -> UIImage?
    func setImage(data: Data, url: URL)
}
