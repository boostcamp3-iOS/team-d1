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
             appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL
    
    func saveImage(image: UIImage, name: String) throws -> String
    func deleteFile(name: String) throws -> String
    func fetchImage(name: String) throws -> UIImage
}

// MARK:- FileManager
extension FileManager: FileManagerProtocol {
    
    // MARK:- Properties
    private var folderName: String {
        return "ArtworkImage"
    }
    
    // MARK:- PostImage folder URL in App
    private func folderURL(name: String) throws -> URL {
        guard let documentDirectory = urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.CreateFolder(message: "Failure access document directory")
        }
        
        let folderURL = documentDirectory.appendingPathComponent(name)
        
        if !fileExists(atPath: folderURL.path) {
            do {
                try createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                throw FileManagerError.CreateFolder(message: error.localizedDescription)
            }
        }
        
        return folderURL
    }
    
    // MARK:- Save image to PostImage folder
    public func saveImage(image: UIImage, name: String) throws -> String {
        let folder = try folderURL(name: folderName)
        let fileName = "\(name).jpg"
        
        let fileDirectory = folder.appendingPathComponent(fileName)
        let jpgImage = UIImage.jpegData(image)
        
        if fileExists(atPath: fileDirectory.path) {
            guard try deleteFile(name: name) == name else {
                throw FileManagerError.Delete(message: "Failure delete file for save new image at \(fileDirectory.path)")
            }
            return try saveImage(image: image, name: name)
        } else {
            guard createFile(atPath: fileDirectory.path, contents: jpgImage(1.0), attributes: nil) else {
                throw FileManagerError.Save(message: "Failure create image file at \(fileDirectory.path)")
            }
        }
        
        return fileName
    }
    
    // MARK:- Delete image from PostImage folder
    @discardableResult
    public func deleteFile(name: String) throws -> String {
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        
        guard fileExists(atPath: fileDirectory.path) else {
            throw FileManagerError.Delete(message: "Couldn't exists file for delete \(name) image")
        }
        
        do {
            try removeItem(atPath: fileDirectory.path)
        } catch let error {
            throw FileManagerError.Delete(message: error.localizedDescription)
        }
        
        return name
    }
    
    // MARK:- Fetch image from PostImage folder
    public func fetchImage(name: String) throws -> UIImage {
        let folder = try folderURL(name: folderName)
        let fileDirectory = folder.appendingPathComponent(name)
        
        guard fileExists(atPath: fileDirectory.path) else {
            throw FileManagerError.Delete(message: "Couldn't read file for fetch \(name) image")
        }
        
        guard let image = UIImage(contentsOfFile: fileDirectory.path) else {
            throw FileManagerError.Fetch(message: "Couldn't fetch \(name) image from")
        }
        
        return image
    }
}

// MARK:- FileManager Error
fileprivate enum FileManagerError: Error {
    case CreateFolder(message: String)
    case Save(message: String)
    case Delete(message: String)
    case Fetch(message: String)
}
