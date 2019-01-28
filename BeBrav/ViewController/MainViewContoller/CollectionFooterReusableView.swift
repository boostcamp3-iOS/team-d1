//
//  CollectionFooterReusableView.swift
//  BeBrav
//
//  Created by 공지원 on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class CollectionFooterReusableView: UICollectionReusableView {
    let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.image = #imageLiteral(resourceName: "add-button")
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setUpViews() {
        addSubview(addButton)
        
        addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
