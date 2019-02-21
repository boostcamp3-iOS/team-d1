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
        textField.font = UIFont.boldSystemFont(ofSize: 32)
        textField.textColor = .white
        textField.isEnabled = false
        return textField
    }()
    
    public let artistIntroTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = ""
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textColor = .white
        textField.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        textField.isEnabled = false
        return textField
    }()
    
    // MARK:- Properties
    public var isEditMode = false {
        didSet {
            artistNameTextField.isEnabled = isEditMode
            artistIntroTextField.isEnabled = isEditMode
            
            if isEditMode {
                artistNameTextField.becomeFirstResponder()
            }
        }
    }
    
    //MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()

        artistNameTextField.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if artistNameTextField.isFirstResponder {
            artistNameTextField.resignFirstResponder()
        } else {
            artistIntroTextField.resignFirstResponder()
        }
    }
    
    //MARK: - Set Layout
    private func setLayout() {
        addSubview(artistNameTextField)
        addSubview(artistIntroTextField)

        backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        artistNameTextField.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        artistNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70).isActive = true
        artistNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70).isActive = true
        
        artistIntroTextField.topAnchor.constraint(equalTo: artistNameTextField.bottomAnchor, constant: 18).isActive = true
        artistIntroTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        artistIntroTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        artistIntroTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
    }
}

//MARK: - Text Field Delegate
extension ArtistDetailHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
