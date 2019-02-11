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
    
    func fetchImage(url: URL) -> UIImage?
    func saveImage (image: UIImage, url: URL) throws
    func deleteImage(url: URL) throws
}

extension DiskCacheProtocol {
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
        
        return "\(fileName).jpg"
    }
    
    // MARK:- Save image to PostImage folder
    public func saveImage(image: UIImage, url: URL) throws {
        let name = try fileName(url: url)
        
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        let jpgImage = UIImage.jpegData(image)
        
        diskCacheList.insert(name)
        
        guard fileManager.createFile(atPath: fileDirectory.path,
                                     contents: jpgImage(1.0),
                                     attributes: nil)
            else
        {
            diskCacheList.remove(name)
            throw DiskCacheError.saveImage
        }
    }
    
    // MARK:- Fetch image from PostImage folder
    public func fetchImage(url: URL) -> UIImage? {
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
    public func deleteImage(url: URL) throws {
        let name = try fileName(url: url)
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        
        defer {
            diskCacheList.remove(name)
        }
        
        guard fileManager.fileExists(atPath: fileDirectory.path) else {
            throw DiskCacheError.deleteImage
        }
        
        try fileManager.removeItem(atPath: fileDirectory.path)
    }
}

// MARK:- FileManager Error
fileprivate enum DiskCacheError: Error {
    case createFolder
    case fileName
    case saveImage
    case deleteImage
}

extension DiskCacheError: CustomNSError {
    static var errorDomain: String = "SQLiteDatabase"
    var errorCode: Int {
        switch self {
        case .createFolder:
            return 200
        case .fileName:
            return 201
        case .saveImage:
            return 202
        case .deleteImage:
            return 203
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case .createFolder:
            return ["Type":"createFolder", "Message":"Failure access document directory"]
        case .fileName:
            return ["Type":"fileName", "Message":"Failure to create file name from URL"]
        case .saveImage:
            return ["Type":"save", "Message":"Failure create image file"]
        case .deleteImage:
            return ["Type":"delete", "Message":"Failure exists file for delete"]
        }
    }
}
