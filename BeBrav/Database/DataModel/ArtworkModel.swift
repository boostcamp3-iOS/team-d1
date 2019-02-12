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
    public let authorId: String
    public let title: String
    public let date: Double
    public let views: Int
    public let imageURL: String
    
    // MARK:- Initialize
    init(id: String,
         authorId: String,
         title: String,
         date: Double,
         imageURL: String,
         views: Int = 0
        )
    {
        self.artworkId = id
        self.authorId = authorId
        self.title = title
        self.date = date
        self.imageURL = imageURL
        self.views = views
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
            || authorId.isEmpty
            || title.isEmpty
            || date < 0.0
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
            "authorId",
            "title",
            "date",
            "views",
            "imageURL"
        ]
    }
    var rows: [Int : String] {
        return [
            0: artworkId,
            1: authorId,
            2: title,
            3: "\(date)",
            4: "\(views)",
            5: imageURL]
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
        self.authorId = ""
        self.title = ""
        self.date = 0.0
        self.imageURL = ""
        self.views = 0
    }
    
    init(data: [String: String]) {
        self.artworkId = data["id"] ?? ""
        self.authorId = data["authorId"] ?? ""
        self.title = data["title"] ?? ""
        self.date = Double(data["date"] ?? "") ?? -0.1
        self.views = Int(data["views"] ?? "") ?? -1
        self.imageURL = data["imageURL"] ?? ""
    }
}

extension ArtworkModel: Equatable {
    static func == (lhs: ArtworkModel, rhs: ArtworkModel) -> Bool {
        return lhs.id == rhs.id && lhs.views == rhs.views
    }
}
