// Artist Collection 첫번째 Section의 Header View
//  SupplementaryView.swift
//  BeBrav
//
//  Created by 공지원 on 23/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtistDetailHeaderView: UICollectionReusableView {
    
    //MARK: - Outlet
    let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "cat1")
        return imageView
    }()
    
    let artistNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "작가이름" //temporary input
        textField.textAlignment = .center
        textField.isEnabled = false
        return textField
    }()
    
    let artistIntroTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개" //temporary input
        textView.isEditable = false
        return textView
    }()
    
    //편집모드 상황을 위한 temporary edit button
    let editButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("편집하기", for: .normal)
        //button.tintColor =
        return button
    }()
    
    var isEditMode = false {
        didSet {
            artistNameTextField.isEnabled = isEditMode
            artistIntroTextView.isEditable = isEditMode
            
            if isEditMode {
                editButton.setTitle("편집완료", for: .normal)
                artistNameTextField.becomeFirstResponder()
            }
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpViews()
        
        editButton.addTarget(self, action: #selector(editButtonDidTap), for: .touchUpInside)
        
        artistNameTextField.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    //편집모드 상황을 위한 temporary action method
    @objc func editButtonDidTap() {
        isEditMode = !isEditMode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if artistNameTextField.isFirstResponder {
            artistNameTextField.resignFirstResponder()
        } else {
            artistIntroTextView.resignFirstResponder()
        }
    }
    
    //TODO: - 편집모드 코드 추가
    
    //MARK: - Set Layout
    private func setUpViews() {
        self.addSubview(editButton) //temporary code
        self.addSubview(artistImageView)
        self.addSubview(artistNameTextField)
        self.addSubview(artistIntroTextView)
        
        //temporary code
        editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        editButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        artistImageView.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        artistImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        artistImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        artistImageView.heightAnchor.constraint(equalTo: artistImageView.widthAnchor, multiplier: 1).isActive = true
        
        artistNameTextField.topAnchor.constraint(equalTo: artistImageView.bottomAnchor, constant: 20).isActive = true
        artistNameTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        artistNameTextField.leadingAnchor.constraint(equalTo: artistIntroTextView.leadingAnchor).isActive = true
        artistNameTextField.trailingAnchor.constraint(equalTo: artistIntroTextView.trailingAnchor).isActive = true
        
        artistIntroTextView.topAnchor.constraint(equalTo: artistNameTextField.bottomAnchor, constant: 20).isActive = true
        artistIntroTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        artistIntroTextView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        artistIntroTextView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
    }
}

//MARK: - Text Field Delegate
extension ArtistDetailHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
