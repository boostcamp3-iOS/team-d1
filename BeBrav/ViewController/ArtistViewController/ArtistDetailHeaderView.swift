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
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "user")
        return imageView
    }()
    
    public let artistNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "작가이름" //temporary input
        textField.textAlignment = .center
        textField.isEnabled = false
        return textField
    }()
    
    public let artistIntroTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개 작가소개" //temporary input
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
        addSubview(artistImageView)
        addSubview(artistNameTextField)
        addSubview(artistIntroTextView)
        
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
