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
        button.setTitle("작품 등록하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return button
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
        
        addArtworkButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        addArtworkButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addArtworkButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addArtworkButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
