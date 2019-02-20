//
//  Post.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct ArtworkModel {
    
    // MARK:- Properties
    private let artworkId: String
    public let userId: String
    public let title: String
    public let timestamp: Double
    public let views: Int
    public let imageURL: String
    public let orientation: Bool
    public let temperature: Bool
    public let color: Bool
    
    // MARK:- Initialize
    init(id: String,
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
        self.userId = authorId
        self.title = title
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.views = views
        self.orientation = orientation
        self.temperature = temperature
        self.color = color
    }
    
    init(artwork:ArtworkDecodeType) {
        self.artworkId = artwork.artworkUid
        self.userId = artwork.userUid
        self.title = artwork.title
        self.timestamp = artwork.timestamp
        self.imageURL = artwork.artworkUrl
        self.views = artwork.views
        self.orientation = artwork.orientation
        self.temperature = artwork.temperature
        self.color = artwork.color
    }
}

// MARK:- ModelProtocol
extension ArtworkModel: DataModelProtocol {
    
    // MARK:- Properties
    public var id: String {
        return artworkId
    }
    public var isEmpty: Bool {
        return id.isEmpty
            || userId.isEmpty
            || title.isEmpty
            || timestamp < 0.0
            || views < 0
    }
    public var tableName: String {
        return "ArtworkTable"
    }
    public var variableList: [String: String] {
        return ["views": "\(views)"]
    }
    var columns: [String] {
        return [
            "id",
            "userId",
            "title",
            "timestamp",
            "views",
            "imageURL",
            "orientation",
            "temperature",
            "color"
        ]
    }
    var rows: [Int : String] {
        return [
            0: artworkId,
            1: userId,
            2: title,
            3: "\(timestamp)",
            4: "\(views)",
            5: imageURL,
            6: "\(orientation ? "" : "1")",
            7: "\(temperature ? "" : "1")",
            8: "\(color ? "" : "1")"
        ]
    }
    
    // MARK:- Set Data
    func setData(data: [String: String]) -> DataModelProtocol {
        return ArtworkModel(data: data)
    }
    
    // MARK:- Is Equal
    func isEqual(model: DataModelProtocol) -> Bool {
        guard let artwork =  model as? ArtworkModel else { return false }
        
        return self == artwork
    }
    
    // MARK:- Initialize
    init() {
        self.artworkId = ""
        self.userId = ""
        self.title = ""
        self.timestamp = 0.0
        self.imageURL = ""
        self.views = 0
        self.orientation = false
        self.temperature = false
        self.color = false
    }
    
    init(data: [String: String]) {
        self.artworkId = data["id"] ?? ""
        self.userId = data["userId"] ?? ""
        self.title = data["title"] ?? ""
        self.timestamp = Double(data["timestamp"] ?? "") ?? -0.1
        self.views = Int(data["views"] ?? "") ?? -1
        self.imageURL = data["imageURL"] ?? ""
        self.orientation = data["orientation"]?.isEmpty ?? false
        self.temperature = data["temperature"]?.isEmpty ?? false
        self.color = data["color"]?.isEmpty ?? false
    }
}

extension ArtworkModel: Equatable {
    static func == (lhs: ArtworkModel, rhs: ArtworkModel) -> Bool {
        return lhs.id == rhs.id && lhs.views == rhs.views
    }
}
