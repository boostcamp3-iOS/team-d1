//
//  ServerManager.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//
import UIKit
import FirebaseModuleProtocols
import NetworkServiceProtocols
import NetworkService
import ImageProcessKit
import Sharing

public struct ServerManager: FirebaseServerService {
    
    public let authManager: FirebaseAuthService
    public let databaseManager: FirebaseDatabaseService
    public let storageManager: FirebaseStorageService
    
    public init(authManager: FirebaseAuthService,
         databaseManager: FirebaseDatabaseService,
         storageManager: FirebaseStorageService) {
        self.authManager = authManager
        self.databaseManager = databaseManager
        self.storageManager = storageManager
    }
    
    public func signUp(email: String,
                password: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> ()) {
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
                                let userData = UserData(uid: uid, description: "", nickName: "", email: email, artworks: [:])
                                let user = [uid: userData]
                                self.databaseManager.write(path: "root/users", data: user, method: .patch, headers: [:]){ (result, response) in
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
    
    public func signIn(email: String,
                password: String,
                completion: @escaping (Result<URLResponseProtocol?>) -> ()) {
        authManager.signIn(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                guard let _ = UserDefaults.standard.string(forKey: "userId"),
                    let _ = UserDefaults.standard.string(forKey: "uid") else {
                        completion(.failure(APIError.invalidData))
                        return
                }
                completion(.success(response))
            }
        }
    }
    
    public func uploadArtwork(image: UIImage,
                       scale: CGFloat,
                       path: String,
                       fileName: String,
                       completion: @escaping (Result<URLResponseProtocol?>)->()) {
        
        //이미지에 분류 알고리즘 적용
        var imageSort = ImageSort(input: image)
        
        guard let r1 = imageSort.orientationSort(), let r2 = imageSort.colorSort(), let r3 = imageSort.temperatureSort() else { return }
        
        var artworkUid = ""
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            completion(.failure(APIError.invalidData))
            return
        }
        let protoArtwork = ArtworkEncodeType(userUid: "",
                                             authorName: "",
                                             uid: artworkUid,
                                             url: "",
                                             title: "",
                                             timestamp: [".sv": "timestamp"],
                                             views: 0,
                                             orientation: r1,
                                             color: r2,
                                             temperature: r3)
        
        self.databaseManager.write(path: "root/users/\(uid)/artworks",
            data: protoArtwork,
            method: .post, headers: [:]) { (result, response) in
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
                        self.databaseManager.read(path: "root/users/\(uid)", type: UserDataDecodeType.self, headers: [:], queries: nil, completion: { (result, response) in
                            switch result {
                            case .failure(let error):
                                print(error)
                            case .success(let data):
                                let downloadUrl = "\(urlString)&token=\(extractedData.downloadTokens)"
                                let artwork = ArtworkEncodeType(userUid: uid,
                                                                authorName: data.nickName,
                                                                uid: artworkUid,
                                                                url: downloadUrl,
                                                                title: fileName,
                                                                timestamp: [".sv": "timestamp"],
                                                                views: Int.random(in: 0...10000),
                                                                orientation: r1,
                                                                color: r2,
                                                                temperature: r3)
                                self.databaseManager.write(path: "root/users/\(uid)/artworks/\(artworkUid)",
                                    data: artwork,
                                    method: .put, headers: [:]) { (result, response) in
                                    switch result {
                                    case .failure(let error):
                                        completion(.failure(error))
                                    case .success:
                                        self.databaseManager.write(path: "root/artworks/\(artworkUid)",
                                            data: artwork,
                                            method: .put, headers: [:]) { (result, response) in
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
                        })
                    }
                }
            }
        }
    }
}
