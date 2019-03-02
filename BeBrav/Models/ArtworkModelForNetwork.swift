//
//  Artwork.swift
//  BeBrav
//
//  Created by bumslap on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//
import UIKit

struct ArtworkEncodeType: Encodable {
    let userUid: String
    let authorName: String
    let artworkUid: String
    let artworkUrl: String
    let title: String
    let timestamp: [String: String]
    let views: Int
    let orientation: Bool
    let color: Bool
    let temperature: Bool
    
    init(userUid: String,
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
    
    init() {
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

struct ArtworkDecodeType: Codable {
    let userUid: String
    let authorName: String
    let artworkUid: String
    let artworkUrl: String
    let timestamp: Double
    let title: String
    var views: Int
    let orientation: Bool
    let color: Bool
    let temperature: Bool
    
    init() {
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
    
    
    init(userUid: String,
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
    
    init(artworkModel: ArtworkModel) {
        self.userUid = artworkModel.userId
        self.authorName = artworkModel.authorName
        self.artworkUid = artworkModel.id
        self.artworkUrl = artworkModel.imageURL
        self.title = artworkModel.title
        self.timestamp = artworkModel.timestamp
        self.views = artworkModel.views
        self.orientation = artworkModel.orientation
        self.color = artworkModel.color
        self.temperature = artworkModel.temperature
    }
    
    init(artwork: Artwork, userName: String, userUid: String) {
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
    static func < (lhs: ArtworkDecodeType, rhs: ArtworkDecodeType) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
}


struct Artworks: Decodable {
    let artworks: [String: ArtworkDecodeType]
}
