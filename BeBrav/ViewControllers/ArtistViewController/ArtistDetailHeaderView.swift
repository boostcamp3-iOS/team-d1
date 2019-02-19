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
    public let artistNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = ""
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.isEnabled = false
        return textField
    }()
    
    public let artistIntroTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = ""
        textView.textAlignment = .center
        textView.isEditable = false
        return textView
    }()
    
    public var isEditMode = false {
        didSet {
            artistNameTextField.isEnabled = isEditMode
            artistIntroTextView.isEditable = isEditMode
            
            if isEditMode {
                artistNameTextField.becomeFirstResponder()
            }
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpViews()

        artistNameTextField.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
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
        addSubview(artistNameTextField)
        addSubview(artistIntroTextView)

        artistNameTextField.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        artistNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70).isActive = true
        artistNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70).isActive = true
        
        artistIntroTextView.topAnchor.constraint(equalTo: artistNameTextField.bottomAnchor, constant: 40).isActive = true
        artistIntroTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        artistIntroTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        artistIntroTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
    }
}

//MARK: - Text Field Delegate
extension ArtistDetailHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
