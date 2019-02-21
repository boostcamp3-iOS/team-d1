//
//  ArtAddCollectionViewCell.swift
//  BeBrav
//
//  Created by 공지원 on 20/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit
import Photos

class ArtAddCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let filtering: UIImageView = {
        let filtering = UIImageView()
        filtering.translatesAutoresizingMaskIntoConstraints = false
        filtering.backgroundColor = .clear
        return filtering
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                filtering.backgroundColor = UIColor(white: 1, alpha: 0.5)
            } else {
                filtering.backgroundColor = .clear
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    func setLayout() {
        contentView.addSubview(imageView)
        imageView.addSubview(filtering)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        filtering.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        filtering.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        filtering.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        filtering.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

    }
}


