//
//  User.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

struct AuthorModel {
    
    // MARK:- Properties
    private let authorId: String
    public let name: String
    public let introduction: String
    
    // MARK:- Initialize
    init(id: String,
         name: String,
         introduction: String
        )
    {
        self.authorId = id
        self.name = name
        self.introduction = introduction
    }
}

// MARK:- ModelProtocol
extension AuthorModel: DataModelProtocol {
    
    // MARK:- Properties
    public var id: String {
        return authorId
    }
    public var isEmpty: Bool {
        return id.isEmpty
            || name.isEmpty
    }
    public var variableList: [String: String] {
        return ["name": name,
                "introduction": introduction
        ]
    }
    public var columns: [String] {
        return ["id",
                "name",
                "introduction"
        ]
    }
    public var rows: [Int: String] {
        return [0: authorId,
                1: name,
                2: introduction
        ]
    }
    
    // MARK;- Initialize
    init() {
        self.authorId = ""
        self.name = ""
        self.introduction = ""
    }
    
    init(data: [String: String]) {
        self.authorId = data["id"] ?? ""
        self.name = data["name"] ?? ""
        self.introduction = data["introduction"] ?? ""
    }
}

extension AuthorModel: Equatable {
    static func == (lhs: AuthorModel, rhs: AuthorModel) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.introduction == rhs.introduction
    }
}
