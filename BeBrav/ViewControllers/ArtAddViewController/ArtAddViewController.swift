//
//  ArtAddViewController.swift
//  TestProject
//
//  Created by 공지원 on 18/02/2019.
//  Copyright © 2019 공지원. All rights reserved.
//

import UIKit

protocol ArtAddViewControllerDelegate: class {
    func uploadArtwork(_ controller: ArtAddViewController, image: UIImage, title: String)
}

class ArtAddViewController: UIViewController {
    
    weak var delegate: ArtAddViewControllerDelegate?
    
    var isReadyUpload: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentSize.height = 1000
        return view
    }()
    
    private let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "cancel"), for: UIControl.State.normal)
        return button
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("등록", for: UIControl.State.normal)
        button.titleLabel?.tintColor = .white
        return button
    }()
    
     let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        //imageView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.3411764706, blue: 1, alpha: 1)
        imageView.isUserInteractionEnabled = true
        //imageView.layer.cornerRadius = 5.0
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
     let plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "add (1)"), for: UIControl.State.normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let orientationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "작품 제목을 입력해주세요."
        return label
    }()
    
    public let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 25)
        textField.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.attributedPlaceholder = NSAttributedString(string: "작품 제목", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)])
        return textField
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "작품 설명을 입력해주세요."
        label.textColor = .white
        return label
    }()
    
    let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "작품의 설명"
        textField.font = UIFont.boldSystemFont(ofSize: 25)
        textField.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.attributedPlaceholder = NSAttributedString(string: "작품 설명", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)])
        return textField
    }()
    
    let alertLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.text = "아직 정보가 부족합니다."
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setTapGestureRecognizer()
        
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        imagePicker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadButtonDidTap), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonDidTap), for: .touchUpInside)
        
        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(descTextFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        self.view.frame.origin.y = -keyboardFrame.height
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func plusButtonDidTap() {
        presentImagePicker()
    }
    
    @objc func titleTextFieldDidChange(_ sender: UITextField) {
        if sender.text?.isEmpty == true {
            inactivateUploadButton()
        } else if descriptionTextField.text?.isEmpty == true {
            inactivateUploadButton()
        } else if imageView.image == nil {
            inactivateUploadButton()
        } else {
            activateUpload()
        }
    }
    
    @objc func descTextFieldDidChange(_ sender: UITextField) {
        if sender.text?.isEmpty == true {
            inactivateUploadButton()
        } else if titleTextField.text?.isEmpty == true {
            inactivateUploadButton()
        } else if imageView.image == nil {
            inactivateUploadButton()
        } else {
            activateUpload()
        }
    }
    
    @objc func cancelButtonDidTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadButtonDidTap() {
        if isReadyUpload == false {
            alertLabel.isHidden = false
        }
        else {
            guard let image = imageView.image, let title = titleTextField.text else { return }
            
            dismiss(animated: true) {
                self.delegate?.uploadArtwork(self, image: image, title: title)
            }
        }
    }
    
    func activateUpload() {
        alertLabel.isHidden = true
        isReadyUpload = true
        uploadButton.setTitleColor(#colorLiteral(red: 0.003921568627, green: 0.3411764706, blue: 1, alpha: 1), for: .normal)
    }
    
    func inactivateUploadButton() {
        isReadyUpload = false
        uploadButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
    
    func presentImagePicker() {
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        orientationLabel.isHidden = true
        colorLabel.isHidden = true
        temperatureLabel.isHidden = true
    }
    
    private func setTapGestureRecognizer() {
        let imageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageViewTapGesture)
    }
    
    @objc func imageViewDidTap() {
        presentImagePicker()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if titleTextField.isFirstResponder == true {
            titleTextField.resignFirstResponder()
        } else {
            descriptionTextField.resignFirstResponder()
        }
    }
    
    private func setUpViews() {
    
        view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.backgroundColor = #colorLiteral(red: 0.1793349345, green: 0.1811105279, blue: 0.1811105279, alpha: 1)
        
        //scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(uploadButton)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(titleTextField)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(descriptionTextField)
        scrollView.addSubview(alertLabel)
        
        imageView.addSubview(plusButton)
        imageView.addSubview(orientationLabel)
        imageView.addSubview(colorLabel)
        imageView.addSubview(temperatureLabel)
        
        cancelButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        cancelButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        
        uploadButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
        uploadButton.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true

        imageView.topAnchor.constraint(equalTo: cancelButton.topAnchor, constant: 50).isActive = true
        imageView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        plusButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        plusButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true

        orientationLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3).isActive = true
        //orientationLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10).isActive = true
        orientationLabel.trailingAnchor.constraint(equalTo: colorLabel.leadingAnchor, constant: -10).isActive = true

        colorLabel.bottomAnchor.constraint(equalTo: orientationLabel.bottomAnchor).isActive = true
        colorLabel.trailingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor, constant: -10).isActive = true

        temperatureLabel.bottomAnchor.constraint(equalTo: colorLabel.bottomAnchor).isActive = true
        temperatureLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true

        titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true

        titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        //titleTextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true

        descriptionLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20).isActive = true

        descriptionTextField.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10).isActive = true
        descriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor).isActive = true
        
        alertLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 15).isActive = true
        alertLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    }
}

extension ArtAddViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ArtAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImageSortResultLabel() {
        orientationLabel.isHidden = false
        colorLabel.isHidden = false
        temperatureLabel.isHidden = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[.editedImage] as? UIImage
        
        imageView.image = editedImage
        plusButton.isHidden = true
        
        dismiss(animated: true) {
            DispatchQueue.global().async {
                var imageSort = ImageSort(input: editedImage)
                
                guard let r1 = imageSort.orientationSort(), let r2 = imageSort.colorSort(), let r3 = imageSort.temperatureSort() else { return }
                
                let orientation = r1 ? "#가로" : "#세로"
                let color = r2 ? "#컬러" : "#흑백"
                let temperature = r3 ? "#차가움" : "#따뜻함"
                
                DispatchQueue.main.async {
                    self.showImageSortResultLabel()
                    
                    self.orientationLabel.text = orientation
                    self.colorLabel.text = color
                    self.temperatureLabel.text = temperature
                    
                    if self.titleTextField.text?.isEmpty == false && self.descriptionTextField.text?.isEmpty == false {
                        self.activateUpload()
                        self.uploadButton.setTitleColor(#colorLiteral(red: 0.003921568627, green: 0.3411764706, blue: 1, alpha: 1), for: .normal)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        showImageSortResultLabel()
        dismiss(animated: true, completion: nil)
    }
}
