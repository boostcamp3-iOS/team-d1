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
    var diskCacheList: Set<String> { get set }
    
    func fetchDiskCacheImage(name: String) -> UIImage?
    func saveDiskCacheImage(image: UIImage, name: String) throws
    func deleteDiskCacheImage(name: String) throws
    func deleteAllDiskCacheImage(name: String) throws
}

extension DiskCacheProtocol {
    // MARK:- PostImage folder URL in App
    private func folderURL(name: String) throws -> URL {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first else
        {
            throw FileManagerError.createFolder(message:
                "Failure access document directory from \(#function) in \(#line)")
        }
        
        let folderURL = documentDirectory.appendingPathComponent(name)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(atPath: folderURL.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch let error {
                throw FileManagerError.createFolder(message: error.localizedDescription)
            }
        }
        
        return folderURL
    }
    
    // MARK:- Save image to PostImage folder
    public func saveDiskCacheImage(image: UIImage, name: String) throws {
        guard !diskCacheList.contains(name) else {
            return
        }
        
        diskCacheList.insert(name)
        
        let folder = try folderURL(name: folderName)
        let fileName = "\(name).jpg"
        let fileDirectory = folder.appendingPathComponent(fileName)
        let jpgImage = UIImage.jpegData(image)
        
        guard fileManager.createFile(atPath: fileDirectory.path,
                                          contents: jpgImage(1.0),
                                          attributes: nil) else
        {
            diskCacheList.remove(name)
            throw FileManagerError.save(message:
                "Failure create image file at \(fileDirectory.path) from \(#function) in \(#line)"
            )
        }
    }
    
    // MARK:- Fetch image from PostImage folder
    public func fetchDiskCacheImage(name: String) -> UIImage? {
        guard let folder = try? folderURL(name: folderName) else {
            return nil
        }
        let fileDirectory = folder.appendingPathComponent(name)
        
        guard let image = UIImage(contentsOfFile: fileDirectory.path) else {
            return nil
        }
        
        diskCacheList.insert(name)

        return image
    }
    
    // MARK:- Delete image from Image folder
    public func deleteDiskCacheImage(name: String) throws {
        let folder = try folderURL(name: folderName)
        let fileName = "\(name).jpg"
        let fileDirectory = folder.appendingPathComponent(fileName)
        
        defer {
            diskCacheList.remove(name)
        }
        
        guard fileManager.fileExists(atPath: fileDirectory.path) else {
            throw FileManagerError.delete(message:
                "Couldn't exists file for delete \(name) image from \(#function) in \(#line)"
            )
        }
        
        do {
            try fileManager.removeItem(atPath: fileDirectory.path)
        } catch let error {
            throw FileManagerError.delete(message: error.localizedDescription)
        }
    }
    
    // MARK:- Delete all image from folder Image
    public func deleteAllDiskCacheImage(name: String) throws {
        diskCacheList.removeAll()
        return
    }
}

// MARK:- FileManager Error
fileprivate enum FileManagerError: Error {
    case createFolder(message: String)
    case save(message: String)
    case delete(message: String)
    case fetch(message: String)
}

extension FileManagerError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .createFolder(_):
            return 200
        case .save(_):
            return 201
        case .delete(_):
            return 202
        case .fetch(_):
            return 203
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case let .createFolder(code):
            return ["File": #file, "Type":"createFolder", "Message":code]
        case let .save(code):
            return ["File": #file, "Type":"save", "Message":code]
        case let .delete(code):
            return ["File": #file, "Type":"delete", "Message":code]
        case let .fetch(code):
            return ["File": #file, "Type":"fetch", "Message":code]
        }
    }
}
