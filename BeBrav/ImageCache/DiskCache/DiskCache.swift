//
//  DiskCache.swift
//  BeBrav
//
//  Created by Seonghun Kim on 11/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class DiskCache: DiskCacheProtocol {
    
    // MARK:- Singleton
    static let shared = DiskCache()
    
    // MARK:- Properties
    public var fileManager: FileManagerProtocol = FileManager.default
    public let folderName = "ArtworkImage"
    private var diskCacheList: Set<String> = []
    
    // MARK:- Image folder URL in App
    private func folderURL(name: String) throws -> URL {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first else
        {
            throw DiskCacheError.createFolder
        }
        
        let folderURL = documentDirectory.appendingPathComponent(name)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(
                atPath: folderURL.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        return folderURL
    }
    
    // MARK:- fileName with https URL
    private func fileName(url: URL) throws -> String {
        guard let uid = url.path.components(separatedBy: "/").last else {
            throw DiskCacheError.fileName
        }
        let fileName = uid.filter{ $0 != "-" }
        
        return fileName
    }
    
    // MARK:- Save image to PostImage folder
    public func saveData(data: Data, url: URL) throws {
        let name = try fileName(url: url)
        
        guard !diskCacheList.contains(name) else { return }
        
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        
        diskCacheList.insert(name)
        
        guard fileManager.createFile(atPath: fileDirectory.path,
                                     contents: data,
                                     attributes: nil)
            else
        {
            diskCacheList.remove(name)
            throw DiskCacheError.saveData
        }
    }
    
    // MARK:- Fetch image from PostImage folder
    public func fetchData(url: URL) -> Data? {
        guard let name = try? fileName(url: url),
            let folder = try? folderURL(name: folderName)
            else
        {
            return nil
        }
        let fileDirectory = folder.appendingPathComponent(name)
        
        guard let data = fileManager.contents(atPath: fileDirectory.path) else {
            return nil
        }
        
        diskCacheList.insert(name)
        
        return data
    }
    
    // MARK:- Delete image from Image folder
    public func deleteData(url: URL) throws {
        let name = try fileName(url: url)
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        
        defer {
            diskCacheList.remove(name)
        }
        
        guard fileManager.fileExists(atPath: fileDirectory.path) else {
            throw DiskCacheError.deleteData
        }
        
        try fileManager.removeItem(atPath: fileDirectory.path)
    }
}

