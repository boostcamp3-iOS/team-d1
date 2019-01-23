//
//  ArtAddModalViewController.swift
//  BeBrav
//
//  Created by 공지원 on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtAddViewController: UIViewController {
    
    //MARK : - Properties
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "작품 등록하기"
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let artImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "add-image"))
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let artNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "작품명을 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    //MARK : - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        //artImageView에 tapGesture를 추가
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(artImageViewTapped))
        artImageView.isUserInteractionEnabled = true
        artImageView.addGestureRecognizer(tapGestureRecognizer)
        
        artNameTextField.delegate = self
    }
    
    //MARK : - Helper Method
    @objc func artImageViewTapped() {
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setUpViews() {
        view.addSubview(artImageView)
        view.addSubview(titleLabel)
        view.addSubview(artNameTextField)
        
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        artImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //artImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        artImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
        //artImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        artImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        //artImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        artImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        artNameTextField.topAnchor.constraint(equalTo: artImageView.bottomAnchor, constant: 20).isActive = true
        artNameTextField.leadingAnchor.constraint(equalTo: artImageView.leadingAnchor).isActive = true
        artNameTextField.trailingAnchor.constraint(equalTo: artImageView.trailingAnchor).isActive = true
    }
}

extension ArtAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        artImageView.image = editedImage
        
        dismiss(animated: true, completion: nil)
    }
}

extension ArtAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        artNameTextField.resignFirstResponder()
    }
}
