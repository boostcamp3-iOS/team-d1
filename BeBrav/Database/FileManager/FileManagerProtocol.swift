//
//  FileManagerProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 29/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

// MARK:- FileManager Protocol
protocol FileManagerProtocol {
    func url(for directory: FileManager.SearchPathDirectory,
             in domain: FileManager.SearchPathDomainMask,
             appropriateFor url: URL?,
             create shouldCreate: Bool) throws -> URL
    
    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    
    func fileExists(atPath path: String) -> Bool
    
    func createDirectory(atPath path:String,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey : Any]?) throws
    
    func createFile(atPath path: String,
                    contents data: Data?,
                    attributes attr: [FileAttributeKey : Any]?) -> Bool
    
    func removeItem(atPath path: String) throws
}

extension FileManager: FileManagerProtocol {
    
}
