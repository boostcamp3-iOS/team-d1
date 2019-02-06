//
//  Artwork.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

struct Artwork {
    let title: String = ""
    let artistName: String = ""
    let artworkImage: UIImage? //TODO: 이후에 URL로 변경
    let views: Int
    let artworkId: String = ""
    var isMostViewedArtwork = false
    
    init(views: Int, image: UIImage?) {
        self.views = views
        self.artworkImage = image
    }
}

extension Artwork: Comparable {
    static func < (lhs: Artwork, rhs: Artwork) -> Bool {
        return lhs.views < rhs.views
    }
}

enum Position: Int {
    case left = 1
    case right = 2
}
