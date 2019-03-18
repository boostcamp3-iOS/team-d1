//
//  NetworkModel.swift
//  BeBrav
//
//  Created by bumslap on 27/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

public struct AuthRequestType: Codable {
   public struct SignUpAndSignIn: Codable {
        public let email: String
        public let password: String
        public let returnSecureToken: Bool
    
        public init (email: String,
              password: String,
              returnSecureToken: Bool) {
            self.email = email
            self.password = password
            self.returnSecureToken = returnSecureToken
        }
    }
}

public enum MimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case json = "application/json"
}

public enum Result<Value> {
    case failure(Error)
    case success(Value)
}

public struct FirebaseAuthResponseType: Codable {
    public let kind: String
    public let idToken: String
    public let email: String
    public let refreshToken: String
    public let expiresIn: String
    public let localId: String
    
    public init(kind: String,
                idToken: String,
                email: String,
                refreshToken: String,
                expiresIn: String,
                localId: String) {
        self.kind = kind
        self.idToken = idToken
        self.email = email
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.localId = localId
        
    }
}

public struct FirebaseStorageResponseDataType: Decodable {
    public let name: String
    public let bucket: String
    public let generation: String
    public let metageneration: String
    public let contentType: String
    public let timeCreated: String
    public let updated: String
    public let storageClass: String
    public let size: String
    public let md5Hash: String
    public let contentEncoding: String
    public let contentDisposition: String
    public let crc32c: String
    public let etag: String
    public let downloadTokens: String
}

public struct FirebaseUidData: Decodable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct UserData: Encodable {
    public let uid: String
    public let description: String
    public let nickName: String
    public let email: String
    public let artworks: [String: ArtworkEncodeType]
    
    public init(uid: String,
         description: String,
         nickName: String,
         email: String,
         artworks: [String: ArtworkEncodeType]) {
        self.uid = uid
        self.description = description
        self.nickName = nickName
        self.email = email
        self.artworks = artworks
    }
}

public struct UserDataDecodeType: Decodable {
    public let uid: String
    public let nickName: String
    public let email: String
    public let description: String
    public let artworks: [String: Artwork]
    
    public init(uid: String, nickName: String, description: String, artworks: [String: Artwork]) {
        self.uid = uid
        self.nickName = nickName
        self.email = ""
        self.description = description
        self.artworks = artworks
    }
}

public struct Artwork: Decodable {
    public let userUid: String
    public let artworkUid: String
    public let artworkUrl: String
    public let timestamp: Double
    public let title: String
    public let views: Int
    public let orientation: Bool
    public let color: Bool
    public let temperature: Bool
    
    public init(artworkModel: ArtworkModel) {
        self.userUid = artworkModel.userId
        self.artworkUrl = artworkModel.imageURL
        self.timestamp = artworkModel.timestamp
        self.title = artworkModel.title
        self.views = artworkModel.views
        self.orientation = artworkModel.orientation
        self.color = artworkModel.color
        self.temperature = artworkModel.temperature
        self.artworkUid = artworkModel.artworkId
    }
}

public struct ArtworkEncodeType: Encodable {
    public let userUid: String
    public let authorName: String
    public let artworkUid: String
    public let artworkUrl: String
    public let title: String
    public let timestamp: [String: String]
    public let views: Int
    public let orientation: Bool
    public let color: Bool
    public let temperature: Bool
    
    public init(userUid: String,
         authorName: String,
         uid: String,
         url: String,
         title: String,
         timestamp: [String: String],
         views: Int,
         orientation: Bool,
         color: Bool,
         temperature: Bool) {
        self.userUid = userUid
        self.authorName = authorName
        self.artworkUid = uid
        self.artworkUrl = url
        self.title = title
        self.timestamp = timestamp
        self.views = views
        self.orientation = orientation
        self.color = color
        self.temperature = temperature
    }
    
    public init() {
        self.authorName = ""
        self.userUid = ""
        self.artworkUid = ""
        self.artworkUrl = ""
        self.title = ""
        self.timestamp = [:]
        self.views = 0
        self.orientation = false
        self.color = false
        self.temperature = false
    }
}

public struct ArtworkDecodeType: Codable {
    public let userUid: String
    public let authorName: String
    public let artworkUid: String
    public let artworkUrl: String
    public let timestamp: Double
    public let title: String
    public var views: Int
    public let orientation: Bool
    public let color: Bool
    public let temperature: Bool
    
    public init() {
        self.userUid = ""
        self.authorName = ""
        self.artworkUid = ""
        self.artworkUrl = ""
        self.title = ""
        self.timestamp = 0
        self.views = 0
        self.orientation = false
        self.color = false
        self.temperature = false
    }
    
    
    public init(userUid: String,
         authorName: String,
         uid: String,
         url: String,
         title: String,
         timestamp: Double,
         views: Int,
         orientation: Bool,
         color: Bool,
         temperature: Bool) {
        self.userUid = userUid
        self.authorName = authorName
        self.artworkUid = uid
        self.artworkUrl = url
        self.title = title
        self.timestamp = timestamp
        self.views = views
        self.orientation = orientation
        self.color = color
        self.temperature = temperature
    }
    
    public init(artworkModel: ArtworkModel) {
        self.userUid = artworkModel.userId
        self.authorName = artworkModel.authorName
        self.artworkUrl = artworkModel.imageURL
        self.title = artworkModel.title
        self.timestamp = artworkModel.timestamp
        self.views = artworkModel.views
        self.orientation = artworkModel.orientation
        self.color = artworkModel.color
        self.temperature = artworkModel.temperature
        self.artworkUid = artworkModel.artworkId
    }
    
    public init(artwork: Artwork, userName: String, userUid: String) {
        self.userUid = userUid
        self.authorName = userName
        self.artworkUid = artwork.artworkUid
        self.artworkUrl = artwork.artworkUrl
        self.title = artwork.title
        self.timestamp = artwork.timestamp
        self.views = artwork.views
        self.orientation = artwork.orientation
        self.color = artwork.color
        self.temperature = artwork.temperature
    }
}



extension ArtworkDecodeType: Comparable {
    public static func < (lhs: ArtworkDecodeType, rhs: ArtworkDecodeType) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
}


struct Artworks: Decodable {
    let artworks: [String: ArtworkDecodeType]
}

public struct ArtworkModel {
    
    // MARK:- Properties
    public let artworkId: String
    public let authorName: String
    public let userId: String
    public let title: String
    public let timestamp: Double
    public let views: Int
    public let imageURL: String
    public let orientation: Bool
    public let temperature: Bool
    public let color: Bool
    
    // MARK:- Initialize
    
    public init() {
        self.artworkId = ""
        self.authorName = ""
        self.userId = ""
        self.title = ""
        self.timestamp = 0.0
        self.imageURL = ""
        self.views = 0
        self.orientation = false
        self.temperature = false
        self.color = false
    }
    
    public init(id: String,
         authorName: String,
         authorId: String,
         title: String,
         timestamp: Double,
         imageURL: String,
         views: Int = 0,
         orientation: Bool,
         temperature: Bool,
         color: Bool
        )
    {
        self.artworkId = id
        self.authorName = authorName
        self.userId = authorId
        self.title = title
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.views = views
        self.orientation = orientation
        self.temperature = temperature
        self.color = color
    }
    
    public init(artwork:ArtworkDecodeType) {
        self.artworkId = artwork.artworkUid
        self.authorName = artwork.authorName
        self.userId = artwork.userUid
        self.title = artwork.title
        self.timestamp = artwork.timestamp
        self.imageURL = artwork.artworkUrl
        self.views = artwork.views
        self.orientation = artwork.orientation
        self.temperature = artwork.temperature
        self.color = artwork.color
    }
    
    public init(data: [String: String]) {
        self.artworkId = data["id"] ?? ""
        self.authorName = data["authorName"] ?? ""
        self.userId = data["userId"] ?? ""
        self.title = data["title"] ?? ""
        self.timestamp = Double(data["timestamp"] ?? "") ?? -0.1
        self.views = Int(data["views"] ?? "") ?? -1
        self.imageURL = data["imageURL"] ?? ""
        self.orientation = (data["orientation"] ?? "") == "0"
        self.temperature = (data["temperature"] ?? "") == "0"
        self.color = (data["color"] ?? "") == "0"
    }
}
