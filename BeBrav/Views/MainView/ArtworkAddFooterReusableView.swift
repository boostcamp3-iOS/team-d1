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
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "keyColor")
        button.layer.cornerRadius = 10
        button.setTitle("작품 등록하기", for: .normal)
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
        UISetUp()
   
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func UISetUp() {
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
