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
    
    func fetchDiskCacheImage(url: URL) -> UIImage?
    func saveDiskCacheImage(image: UIImage, url: URL) throws
    func deleteDiskCacheImage(url: URL) throws
}

extension DiskCacheProtocol {
    // MARK:- Image folder URL in App
    private func folderURL(name: String) throws -> URL {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first else
        {
            throw DiskCacheError.createFolder(
                message: "Failure access document directory from \(#function) in \(#line)"
            )
        }
        
        let folderURL = documentDirectory.appendingPathComponent(name)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(
                    atPath: folderURL.path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch let error {
                throw DiskCacheError.createFolder(message: error.localizedDescription)
            }
        }
        
        return folderURL
    }
    
    // MARK:- fileName with https URL
    private func fileName(url: URL) throws -> String {
        guard let uid = url.path.components(separatedBy: "/").last else {
            throw DiskCacheError.fileName(message: "Failure to read file name")
        }
        let fileName = uid.filter{ $0 != "-" }
        
        return "\(fileName).jpg"
    }
    
    // MARK:- Save image to PostImage folder
    public func saveDiskCacheImage(image: UIImage, url: URL) throws {
        let name = try fileName(url: url)
        
        guard !diskCacheList.contains(name) else {
            throw DiskCacheError.fileName(message: "Failure to read file name")
        }
        
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        let jpgImage = UIImage.jpegData(image)
        
        diskCacheList.insert(name)
        
        guard fileManager.createFile(atPath: fileDirectory.path,
                                     contents: jpgImage(1.0),
                                     attributes: nil
            ) else
        {
            diskCacheList.remove(name)
            throw DiskCacheError.save(
                message: "Failure create image file at \(fileDirectory.path) from \(#function) in \(#line)"
            )
        }
    }
    
    // MARK:- Fetch image from PostImage folder
    public func fetchDiskCacheImage(url: URL) -> UIImage? {
        guard let name = try? fileName(url: url),
            let folder = try? folderURL(name: folderName)
            else
        {
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
    public func deleteDiskCacheImage(url: URL) throws {
        let name = try fileName(url: url)
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        
        defer {
            diskCacheList.remove(name)
        }
        
        guard fileManager.fileExists(atPath: fileDirectory.path) else {
            throw DiskCacheError.delete(
                message: "Couldn't exists file for delete \(name) image from \(#function) in \(#line)"
            )
        }
        
        do {
            try fileManager.removeItem(atPath: fileDirectory.path)
        } catch let error {
            throw DiskCacheError.delete(message: error.localizedDescription)
        }
    }
}

// MARK:- FileManager Error
fileprivate enum DiskCacheError: Error {
    case createFolder(message: String)
    case fileName(message: String)
    case save(message: String)
    case delete(message: String)
    case fetch(message: String)
}

extension DiskCacheError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .createFolder:
            return 200
        case .save:
            return 201
        case .delete:
            return 202
        case .fetch:
            return 203
        case .fileName:
            return 204
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case let .createFolder(code):
            return ["File": #file, "Type":"createFolder", "Message":"Failure access document directory"]
        case let .save(code):
            return ["File": #file, "Type":"save", "Message":code]
        case let .delete(code):
            return ["File": #file, "Type":"delete", "Message":code]
        case let .fetch(code):
            return ["File": #file, "Type":"fetch", "Message":code]
        case let .fileName(code):
            return ["File": #file, "Type":"fileName", "Message":code]
        }
    }
}
