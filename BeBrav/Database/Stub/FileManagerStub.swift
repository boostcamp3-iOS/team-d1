//
//  MockFileManager.swift
//  BeBrav
//
//  Created by Seonghun Kim on 29/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class FileManagerStub: FileManagerProtocol {
    
    func url(for directory: FileManager.SearchPathDirectory,
             in domain: FileManager.SearchPathDomainMask,
             appropriateFor url: URL?, create shouldCreate: Bool)
        throws -> URL
    {
        return URL(fileURLWithPath: "")
    }
    
    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask)
        -> [URL]
    {
        return []
    }
    
    func fileExists(atPath path: String) -> Bool {
        return true
    }
    
    func createDirectory(atPath path: String,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey : Any]?) throws
    {
        return
    }
    
    func createFile(atPath path: String, contents data: Data?,
                    attributes attr: [FileAttributeKey : Any]?)
        -> Bool
    {
        return true
    }
    
    func removeItem(atPath path: String) throws {
        return
    }
    
    func contents(atPath: String) -> Data? {
        return Data()
    }
}
