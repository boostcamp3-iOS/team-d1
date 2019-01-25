//
//  MainAutoResizingViewCell.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MainAutoResizingCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error")
    }
    
    private func setLayout() {
        contentView.addSubview(artworkImageView)
        artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        artworkImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        artworkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    // MARK: UI
    let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
}
