//
//  NetworkModel.swift
//  BeBrav
//
//  Created by bumslap on 27/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//


import Foundation

enum MimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case json = "application/json"
}

struct FirebaseAuthResponseType: Codable {
    let kind: String
    let idToken: String
    let email: String
    let refreshToken: String
    let expiresIn: String
    let localId: String
}

struct FirebaseStorageResponseDataType: Decodable {
    let name: String
    let bucket: String
    let generation: String
    let metageneration: String
    let contentType: String
    let timeCreated: String
    let updated: String
    let storageClass: String
    let size: String
    let md5Hash: String
    let contentEncoding: String
    let contentDisposition: String
    let crc32c: String
    let etag: String
    let downloadTokens: String
}

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

