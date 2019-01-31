//
//  MockFileManager.swift
//  BeBrav
//
//  Created by Seonghun Kim on 29/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class FileManagerStub: FileManagerProtocol {
    func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL {
        return URL(fileURLWithPath: "")
    }
    
    func saveImage(image: UIImage, name: String) throws -> String {
        return ""
    }
    
    func deleteFile(name: String) throws -> String {
        return ""
    }
    
    func fetchImage(name: String) throws -> UIImage {
        return UIImage()
    }
}
