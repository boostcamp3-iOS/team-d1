//
//  ImageCacheProtocol.swift
//  BeBrav
//
//  Created by Seonghun Kim on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ImageLoader: ImageLoaderProtocol {
    
    // MARK:- Properties
    public let session: URLSessionProtocol
    public let diskCache: DiskCacheProtocol
    public let memoryCache: MemoryCacheProtocol
    
    private var taskList: [String: URLSessionTaskProtocol] = [:]
    
    // MARK:- Initialize
    required init(session: URLSessionProtocol,
                  diskCache: DiskCacheProtocol,
                  memoryCache: MemoryCacheProtocol)
    {
        self.session = session
        self.diskCache = diskCache
        self.memoryCache = memoryCache
    }
    
    // MARK:- Fetch image with caching
    public func fetchImage(url: URL,
                           size: ImageSize = .small,
                           prefetching: Bool = false,
                           completion: @escaping (UIImage?, Error?) -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = self.fetchCacheImage(url: url, size: size) {
                completion(image,nil)
                return
            }
            
            self.downloadImage(url: url,
                               size: size,
                               prefetching: prefetching,
                               completion: completion)
        }
    }
    
    public func cancelDownloadImage(url: URL) {
        guard let task = taskList[url.path] else { return }
        
        if task.state == .running || task.state == .suspended {
            task.cancel()
        }
        
        taskList.removeValue(forKey: url.path)
    }
    
    // MARK:- Download Image
    private func downloadImage(url: URL,
                               size: ImageSize,
                               prefetching: Bool,
                               completion: @escaping (UIImage?, Error?) -> Void)
    {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        if let task = taskList[url.path] {
            switch task.state {
            case .running:
                completion(nil, APIError.waitRequest)
                return
            case .suspended:
                task.resume()
                return
            case .canceling, .completed:
                taskList.removeValue(forKey: url.path)
            }
        }
        
        let dataTask = imageDownloadDataTask(url: url,
                                             size: size,
                                             prefetching: prefetching,
                                             completion: completion)
        
        dataTask.resume()
        taskList[url.path] = dataTask
    }
    
    private func imageDownloadDataTask(url: URL,
                                       size: ImageSize,
                                       prefetching: Bool,
                                       completion: @escaping (UIImage?, Error?) -> Void)
        -> URLSessionTaskProtocol
    {
        return session.dataTask(with: url) { (data, reponse, error) in
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                self.taskList.removeValue(forKey: url.path)
            }
            
            if let error =  error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, APIError.invalidData)
                return
            }
            
            self.saveCacheImage(url: url, data: data)
            
            if prefetching {
                completion(nil, nil)
                return
            }
            
            guard let image = UIImage(data: data)?.scale(with: size.rawValue) else {
                completion(nil, APIError.invalidData)
                return
            }
            
            completion(image,nil)
        }
    }
    
    // MARK:- Fetch cache image
    private func fetchCacheImage(url: URL, size: ImageSize) -> UIImage? {
        if let image = memoryCache.fetchImage(url: url) {
            let resizedImage = image.scale(with: size.rawValue)
            return resizedImage
        }
        
        if let data = diskCache.fetchData(url: url),
            let image = UIImage(data: data)
        {
            DispatchQueue.global(qos: .userInitiated).async {
                self.memoryCache.setImage(data: data, url: url)
            }
            
            let resizedImage = image.scale(with: size.rawValue)
            
            return resizedImage
        }
        
        return nil
    }
    
    // MARK:- Save cache image
    private func saveCacheImage(url: URL, data: Data) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.memoryCache.setImage(data: data, url: url)
        }
        
        DispatchQueue.global(qos: .utility).async {
            do  {
                try self.diskCache.saveData(data: data, url: url)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK:- Image size
enum ImageSize: CGFloat {
    case big = 1
    case small = 0.4
}
