//
//  Post.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import FirebaseService
import Sharing


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
            "authorName",
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
            1: authorName,
            2: userId,
            3: title,
            4: "\(timestamp)",
            5: "\(views)",
            6: imageURL,
            7: "\(orientation ? "0" : "1")",
            8: "\(temperature ? "0" : "1")",
            9: "\(color ? "0" : "1")"
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

}

// MARK:- ArtworkModel Equatable
extension ArtworkModel: Equatable {
    public static func == (lhs: ArtworkModel, rhs: ArtworkModel) -> Bool {
        return lhs.id == rhs.id && lhs.views == rhs.views
    }
}
