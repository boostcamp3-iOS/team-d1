//
//  ArtAddCell.swift
//  BeBrav
//
//  Created by 공지원 on 12/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol ArtAddCellDelegate: class {
    func presentImagePicker(_ cell: ArtAddCell)
    func enableScroll(_ cell: ArtAddCell)
    func disableScroll(_cell: ArtAddCell)
}

class ArtAddCell: UICollectionViewCell {
    
    weak var delegate: ArtAddCellDelegate?
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "cancel"), for: UIControl.State.normal)
        return button
    }()
    
    let upArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "grayArrow")
        return imageView
    }()
    
    let uploadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "위로 슬라이드해서 업로드"
        label.textColor = #colorLiteral(red: 0.1306727415, green: 0.2843763849, blue: 0.8549019694, alpha: 1)
        label.isHidden = true
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
        return button
    }()
    
    let orientationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "작품 제목:"
        return label
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "작품의 제목을 입력해주세요."
        textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.tag = 100
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "작품 설명:"
        label.textColor = .white
        return label
    }()
    
    let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "작품의 설명을 입력해주세요."
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.tag = 101
        return textField
    }()
    
    //    let descriptionTextView: UITextView = {
    //        let textView = UITextView()
    //        textView.translatesAutoresizingMaskIntoConstraints = false
    //        textView.text = "descriptionTextView"
    //        textView.backgroundColor = .white
    //        return textView
    //    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpViews()
        
        setTapGestureRecognizer()
        
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonDidTap), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK : - Helper Method
    @objc func cancelButtonDidTap() {
        print("cancelButtonDidTap")
        //TODO : - dismiss
    }
    
    @objc func plusButtonDidTap() {
        delegate?.presentImagePicker(self)
    }
    
    private func setTapGestureRecognizer() {
        let imageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageViewTapGesture)
        
        let cellBackgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellBackgroundViewDidTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(cellBackgroundTapGesture)
    }
    
    @objc func imageViewDidTap() {
        delegate?.presentImagePicker(self)
    }
    
    //TODO : - return키 외에 배경 눌러도 키보드 내려가도록 하기
    @objc private func cellBackgroundViewDidTap() {
        print("cellBackgroundViewDidTap")
    }
    
    private func setUpViews() {
        
        backgroundColor = .black
        
        addSubview(cancelButton)
        addSubview(upArrowImageView)
        addSubview(uploadLabel)
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(titleTextField)
        addSubview(descriptionLabel)
        addSubview(descriptionTextField)
        //addSubview(descriptionTextView)
        
        imageView.addSubview(plusButton)
        imageView.addSubview(orientationLabel)
        imageView.addSubview(colorLabel)
        imageView.addSubview(temperatureLabel)
        
        cancelButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        upArrowImageView.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        upArrowImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        upArrowImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        uploadLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        uploadLabel.topAnchor.constraint(equalTo: upArrowImageView.bottomAnchor, constant: 15).isActive = true
        
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        imageView.topAnchor.constraint(equalTo: uploadLabel.bottomAnchor, constant: 30).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        plusButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        plusButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        orientationLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10).isActive = true
        orientationLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -130).isActive = true
        
        colorLabel.bottomAnchor.constraint(equalTo: orientationLabel.bottomAnchor).isActive = true
        colorLabel.leadingAnchor.constraint(equalTo: orientationLabel.trailingAnchor, constant: 10).isActive = true
        
        temperatureLabel.bottomAnchor.constraint(equalTo: colorLabel.bottomAnchor).isActive = true
        temperatureLabel.leadingAnchor.constraint(equalTo: colorLabel.trailingAnchor, constant: 10).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40 ).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        
        titleTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10).isActive = true
        titleTextField.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        //titleTextField.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        
        descriptionTextField.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 10).isActive = true
        descriptionTextField.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
        
        //        descriptionTextView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 10).isActive = true
        //        descriptionTextView.leadingAnchor.constraint(equalTo: descriptionTextField.leadingAnchor).isActive = true
        //        descriptionTextView.trailingAnchor.constraint(equalTo: descriptionTextField.trailingAnchor).isActive = true
        //        descriptionTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
}

//MARK : - TextField Delegate
extension ArtAddCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        delegate?.enableScroll(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let titleTextField = viewWithTag(100) as? UITextField else { return }
        guard let descTextField = viewWithTag(101) as? UITextField else { return }
        
        if imageView.image != nil && titleTextField.text?.isEmpty == false && descTextField.text?.isEmpty == false {
            upArrowImageView.image = #imageLiteral(resourceName: "blueArrow")
            uploadLabel.isHidden = false
            delegate?.enableScroll(self)
        } else {
            upArrowImageView.image = #imageLiteral(resourceName: "grayArrow")
            uploadLabel.isHidden = true
            delegate?.disableScroll(_cell: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
