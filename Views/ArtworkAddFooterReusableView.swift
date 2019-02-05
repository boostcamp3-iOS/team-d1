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
    
    /*let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 38)
        label.textColor = UIColor.white
        return label
    }()*/
    

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
        //addSubview(userNameLabel)
        addArtworkButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        addArtworkButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addArtworkButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        addArtworkButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
       /*
        userNameLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        userNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        */
    }
}
