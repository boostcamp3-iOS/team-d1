//
//  PhotoListCollectionViewCell.swift
//  BeBrav
//
//  Created by Seonghun Kim on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class PhotoListCollectionViewCell: UICollectionViewCell {
    
    // MARK:- Outlet
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK:- Properties
    override var isSelected: Bool {
        didSet {
            ChangeCellLayout(isSelected: isSelected)
        }
    }
    
    // MARK:- Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setLayout()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        isSelected = false
    }
    
    // MARK:- ChangeCellLayout
    private func ChangeCellLayout(isSelected: Bool) {
        imageView.alpha = isSelected ? 0.5 : 1.0
        
        contentView.layer.borderColor = isSelected ? #colorLiteral(red: 7.121353701e-05, green: 0.3243641257, blue: 0.9695228934, alpha: 1) : UIColor.clear.cgColor
    }
    
    // MARK:- Set Layout
    private func setLayout() {
        contentView.addSubview(imageView)
        contentView.layer.borderWidth = 5
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}
