// Artist Collection View의 Header View
//  SupplementaryView.swift
//  BeBrav
//
//  Created by 공지원 on 23/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class SupplementaryView: UICollectionReusableView {
    
    //MARK: - Properties
    let artistImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "user"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let artistTextField: UITextField = {
        let textField = UITextField()
        textField.text = "공지원" //temporary input
        textField.isEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let artistIntroTextField: UITextField = {
        let textField = UITextField()
        textField.text = "아티스트 소개글아티스트 소개글아티스트 소개글아티스트 소개글아티스트 소개글아티스트 소개글아티스트 소개글아티스트 소개글아티스트" //temporary input
        textField.isEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpViews()
        
        backgroundColor = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Set Layout
extension SupplementaryView {
    private func setUpViews() {
        self.addSubview(artistImageView)
        self.addSubview(artistTextField)
        self.addSubview(artistIntroTextField)
        
        artistImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        artistImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        artistImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        artistImageView.heightAnchor.constraint(equalTo: artistImageView.widthAnchor, multiplier: 1).isActive = true
        
        artistTextField.topAnchor.constraint(equalTo: artistImageView.bottomAnchor, constant: 30).isActive = true
        artistTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        artistIntroTextField.topAnchor.constraint(equalTo: artistTextField.bottomAnchor, constant: 20).isActive = true
        artistIntroTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        artistIntroTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        //artistIntroLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20).isActive = true
    }
}
