//
//  ArtworkAddFooterReusableView.swift
//  BeBrav
//
//  Created by bumslap on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtworkAddFooterReusableView: UICollectionReusableView {
    
    let addArtworkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.002250103978, green: 0.3397829235, blue: 1, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitle("newArtwork".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return button
    }()

    let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .gray
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        addSubview(addArtworkButton)
        addSubview(indicator)
        
        addArtworkButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        addArtworkButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addArtworkButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addArtworkButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        indicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.topAnchor.constraint(equalTo: addArtworkButton.bottomAnchor, constant: 8).isActive = true
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
