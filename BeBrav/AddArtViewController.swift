//  작품 등록 화면
//  ArtAddModalViewController.swift
//  BeBrav
//
//  Created by 공지원 on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class ArtAddViewController: UIViewController {
    
    //MARK: - Properties
    let navigationBar: UINavigationBar = {
        let naviBar = UINavigationBar()
        naviBar.translatesAutoresizingMaskIntoConstraints = false
        return naviBar
    }()
    
    let naviItem: UINavigationItem = {
        let item = UINavigationItem(title: "작품 등록")
        return item
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "작품 등록하기"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    let artImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "add-image"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let artNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "작품명을 입력해주세요."
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    lazy var rightBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "등록", style: .plain, target: self, action: #selector(rightBarButtonDidTap))
        button.title = "등록"
        return button
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artNameTextField.delegate = self
        imagePicker.delegate = self
        
        setUpViews()
        
        setTapGestureRecognizer()
    }
    
    //MARK: - Helper Method
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(artImageViewDidTap))
        artImageView.isUserInteractionEnabled = true
        artImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func artImageViewDidTap() {
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - TODO
    @objc func rightBarButtonDidTap() {
        print("rightBarButtonDidTap")
        //TODO: - register image...
    }
    
    //MARK: - Set Layout
    private func setUpViews() {
        navigationBar.pushItem(naviItem, animated: true)
        naviItem.rightBarButtonItem = rightBarButton
        
        view.addSubview(navigationBar)
        view.addSubview(artImageView)
        view.addSubview(titleLabel)
        view.addSubview(artNameTextField)
        
        navigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 3).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        artImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        artImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        artImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        artImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        artNameTextField.topAnchor.constraint(equalTo: artImageView.bottomAnchor, constant: 15).isActive = true
        artNameTextField.leadingAnchor.constraint(equalTo: artImageView.leadingAnchor).isActive = true
        artNameTextField.trailingAnchor.constraint(equalTo: artImageView.trailingAnchor).isActive = true
    }
}

//MARK: - Image Picker Delegate
extension ArtAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        artImageView.image = editedImage
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - TextField Delegate
extension ArtAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        artNameTextField.resignFirstResponder()
    }
}
