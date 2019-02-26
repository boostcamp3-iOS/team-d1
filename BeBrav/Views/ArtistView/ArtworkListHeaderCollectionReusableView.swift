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
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "artworks".localized
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.isHidden = true
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
        
        backgroundColor = #colorLiteral(red: 0.1780431867, green: 0.1711916029, blue: 0.2278442085, alpha: 1)
        
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    }
}
