//
//  User.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct ArtistModel {
    
    // MARK:- Properties
    private let artistId: String
    public let name: String
    public let description: String
    
    // MARK:- Initialize
    init(id: String,
         name: String,
         description: String
        )
    {
        self.artistId = id
        self.name = name
        self.description = description
    }
}

// MARK:- ModelProtocol
extension ArtistModel: DataModelProtocol {
    
    // MARK:- Properties
    public var id: String {
        return artistId
    }
    public var isEmpty: Bool {
        return id.isEmpty
            || name.isEmpty
    }
    public var tableName: String {
        return "ArtistTable"
    }
    public var variableList: [String: String] {
        return [
            "name": name,
            "description": description
        ]
    }
    public var columns: [String] {
        return [
            "id",
            "name",
            "description"
        ]
    }
    public var rows: [Int: String] {
        return [
            0: artistId,
            1: name,
            2: description
        ]
    }
    
    // MARK:- Set Data
    func setData(data: [String: String]) -> DataModelProtocol {
        return ArtistModel(data: data)
    }
    
    // MARK:- Is Equal
    func isEqual(model: DataModelProtocol) -> Bool {
        guard let artist =  model as? ArtistModel else { return false }
        
        return self == artist
    }
    
    // MARK:- Initialize
    init() {
        self.artistId = ""
        self.name = ""
        self.description = ""
    }
    
    init(data: [String: String]) {
        self.artistId = data["id"] ?? ""
        self.name = data["name"] ?? ""
        self.description = data["description"] ?? ""
    }
}

// MARK:- ArtistModel Equatable
extension ArtistModel: Equatable {
    static func == (lhs: ArtistModel, rhs: ArtistModel) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.description == rhs.description
    }
}
