//
//  ServerManager.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

struct ServerManager {
    
    let authManager: FirebaseAuthService
    let databaseManager: FirebaseDatabaseService
    let storageManager: FirebaseStorageService
    let uid: String //TODO: uid를 넣어서 사용할 수 있도록 구현
    
    init(authManager: FirebaseAuthService,
         databaseManager: FirebaseDatabaseService,
         storageManager: FirebaseStorageService, uid: String) {
        self.authManager = authManager
        self.databaseManager = databaseManager
        self.storageManager = storageManager
        self.uid = uid
    }
    
    func signUp(email: String,
                password: String,
                completion: @escaping (Result<URLResponse?>) -> ()) {
        authManager.signUp(email: email,
                           password: password) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                guard let email = UserDefaults.standard.string(forKey: "userId"),
                    let uid = UserDefaults.standard.string(forKey: "uid") else {
                        completion(.failure(APIError.invalidData))
                        return
                }
                let userData = UserData(uid: uid, nickName: "", email: email, userProfileUrl: "", artworks: [:])
                let user = [uid: userData]
                self.databaseManager.write(path: "root/users", data: user, method: .patch){ (result, response) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        completion(.success(response))
                    }
                }
            }
        }
    }
    
    func signIn(email: String,
                password: String,
                completion: @escaping (Result<URLResponse?>) -> ()) {
        authManager.signIn(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                guard let email = UserDefaults.standard.string(forKey: "userId"),
                    let uid = UserDefaults.standard.string(forKey: "uid") else {
                        completion(.failure(APIError.invalidData))
                        return
                }
                completion(.success(response))
            }
        }
    }
    
    func uploadArtwork(image: UIImage,
                       scale: CGFloat,
                       path: String,
                       fileName: String,
                       completion: @escaping (Result<URLResponse?>)->()) {
        var artworkUid = ""
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            completion(.failure(APIError.invalidData))
            return
        }
        let protoArtwork = ArtworkEncodeType(uid: artworkUid,
                                   url: "",
                                        title: "",
                                        timestamp: [:],
                                        views: 0,
                                        orientation: false,
                                        color: false,
                                        temperature: false)
        
        self.databaseManager.write(path: "root/users/\(uid)/artworks",
                                   data: protoArtwork,
                                   method: .post) { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let uidData =
                    self.storageManager.parser.extractDecodedJsonData(decodeType: FirebaseUidData.self,
                                                                      binaryData: data)
                    else {
                        completion(.failure(APIError.jsonParsingFailure))
                    return
                }
                artworkUid = uidData.name
                self.storageManager.post(image: image,
                                    scale: scale,
                                    path: path,
                                    fileName: artworkUid) { (result, response) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        guard let extractedData =
                            self.storageManager.parser.extractDecodedJsonData(decodeType: FirebaseStorageResponseDataType.self,
                                                                              binaryData: data)
                            else {
                                completion(.failure(APIError.jsonParsingFailure))
                                return
                        }
                        guard let urlString = response?.url?.absoluteString else {
                            completion(.failure(APIError.invalidData))
                            return
                        }
                        let downloadUrl = "\(urlString)&token=\(extractedData.downloadTokens)"
                        let artwork = ArtworkEncodeType(uid: artworkUid,
                                              url: downloadUrl,
                                              title: fileName,
                                              timestamp: [".sv": "timestamp"],
                                              views: Int.random(in: 0...10000),
                                              orientation: false,
                                              color: false,
                                              temperature: false)
                        self.databaseManager.write(path: "root/users/\(uid)/artworks/\(artworkUid)",
                                                   data: artwork,
                                                   method: .put) { (result, response) in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success:
                                self.databaseManager.write(path: "root/artworks/\(artworkUid)",
                                    data: artwork,
                                    method: .put) { (result, response) in
                                        switch result {
                                        case .failure(let error):
                                            completion(.failure(error))
                                        case .success:
                                            completion(.success(response))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

