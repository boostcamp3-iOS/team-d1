//
//  PhotoListHeaderCollectionReusableView.swift
//  BeBrav
//
//  Created by Seonghun Kim on 24/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class PhotoListHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK:- Outlet
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Photos"
        return label
    }()
    
    public lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        // TODO: 삭제아이콘 추가시 타이틀 삭제 및 버튼 이미지 추가
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
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
        addSubview(deleteButton)
        
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        
        deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
}
