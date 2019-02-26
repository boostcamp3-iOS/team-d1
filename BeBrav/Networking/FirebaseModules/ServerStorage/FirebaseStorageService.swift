//
//  FirebaseStorageService.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol FirebaseStorageService: FirebaseService {
    
    func get(path: String,
             fileName: String,
             completion: @escaping (Result<String>) -> Void)
    
    func post(image: UIImage, scale: CGFloat, path: String, fileName: String,
              completion: @escaping (Result<Data>, URLResponseProtocol?)->())
    
    func delete(path: String,
                fileName: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> Void)
}
