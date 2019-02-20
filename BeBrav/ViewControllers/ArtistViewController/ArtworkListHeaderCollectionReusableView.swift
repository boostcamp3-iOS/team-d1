//
//  PhotoListHeaderCollectionReusableView.swift
//  BeBrav
//
//  Created by Seonghun Kim on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtworkListHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK:- Outlet
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Photos"
        label.textColor = .white
        return label
    }()
    
    // MARK:- Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setLayout()
    }
    
    // MARK:- Set Layout
    private func setLayout() {
        addSubview(titleLabel)
        
        backgroundColor = .black
        
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    }
}
