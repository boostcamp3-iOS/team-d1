//
//  SignUpViewController.swift
//  BeBrav
//
//  Created by bumslap on 14/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let serverAuth: FirebaseAuthService
    private let serverDatabase: FirebaseDatabaseService
    
    init(serverAuth: FirebaseAuthService, serverDatabase: FirebaseDatabaseService) {
        self.serverAuth = serverAuth
        self.serverDatabase = serverDatabase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var textFields: [UITextField] = []
    private var bottomConstraintOfButton: NSLayoutConstraint?
    private var currentTextField: UITextField?
    private var latestOffset: CGPoint = CGPoint.zero
    
    private let keyboardPadding = 16
    
    private let signUpScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.noticeLabel.text = "verifying"
        return indicator
    }()
    
    private let inputEmailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 36)
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "이메일"
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string:"이메일",
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedEmailUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "이메일 주소를 입력해주세요"
        label.textColor = .white
        return label
    }()
    
    private let inputPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 36)
        textField.clearButtonMode = .whileEditing
        textField.textContentType = .newPassword
        textField.autocapitalizationType = .none
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string:"비밀번호",
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedPasswordUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "비밀번호를 입력해주세요"
        label.textColor = .white
        return label
    }()
    
    private let inputNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 36)
        textField.keyboardAppearance = .dark
        textField.clearButtonMode = .whileEditing
        textField.textContentType = .username
        textField.autocapitalizationType = .none
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string:"이름",
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedNameUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "이름를 입력해주세요"
        label.textColor = .white
        return label
    }()
    
    private let fixedConfirmLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "아직 정보가 부족합니다."
        label.textColor = .red
        return label
    }()
    
    private let approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.setTitle("가입 완료", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        inputEmailTextField.delegate = self
        inputPasswordTextField.delegate = self
        inputNameTextField.delegate = self
        textFields = [
            inputEmailTextField,
            inputPasswordTextField,
            inputNameTextField
        ]
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyboard), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyboard), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        
    }
    
    func setLayout() {
        
        navigationItem.title = "회원가입"
        
        view.addSubview(signUpScrollView)
        
        signUpScrollView.backgroundColor = UIColor(named: "backgroundColor")
        
        signUpScrollView.addSubview(fixedEmailUpperLabel)
        signUpScrollView.addSubview(inputEmailTextField)
        
        signUpScrollView.addSubview(fixedPasswordUpperLabel)
        signUpScrollView.addSubview(inputPasswordTextField)
        
        signUpScrollView.addSubview(fixedNameUpperLabel)
        signUpScrollView.addSubview(inputNameTextField)
        
        signUpScrollView.addSubview(fixedConfirmLabel)
        
        signUpScrollView.addSubview(approveButton)
        
        signUpScrollView.addSubview(loadingIndicator)
        
        
        signUpScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        signUpScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        signUpScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        signUpScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        loadingIndicator.deactivateIndicatorView()
        
        fixedEmailUpperLabel.topAnchor.constraint(equalTo: signUpScrollView.topAnchor, constant: 54).isActive = true
        fixedEmailUpperLabel.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 20).isActive = true
        
        inputEmailTextField.topAnchor.constraint(equalTo: fixedEmailUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputEmailTextField.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        inputEmailTextField.trailingAnchor.constraint(equalTo: signUpScrollView.trailingAnchor, constant: -16).isActive = true
        
        fixedPasswordUpperLabel.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor, constant: 20).isActive = true
        fixedPasswordUpperLabel.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        
        inputPasswordTextField.topAnchor.constraint(equalTo: fixedPasswordUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputPasswordTextField.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        inputNameTextField.widthAnchor.constraint(equalTo: signUpScrollView.widthAnchor, multiplier: 0.8).isActive = true
        inputPasswordTextField.trailingAnchor.constraint(equalTo: signUpScrollView.trailingAnchor, constant: 0).isActive = true
        
        fixedNameUpperLabel.topAnchor.constraint(equalTo: inputPasswordTextField.bottomAnchor, constant: 20).isActive = true
        fixedNameUpperLabel.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        
        inputNameTextField.topAnchor.constraint(equalTo: fixedNameUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputNameTextField.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        inputNameTextField.trailingAnchor.constraint(equalTo: signUpScrollView.trailingAnchor, constant: -16).isActive = true
        
        fixedConfirmLabel.topAnchor.constraint(equalTo: inputNameTextField.bottomAnchor, constant: 46).isActive = true
        fixedConfirmLabel.centerXAnchor.constraint(equalTo: signUpScrollView.centerXAnchor).isActive = true
        
        bottomConstraintOfButton = NSLayoutConstraint(item: approveButton, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraintOfButton?.isActive = true
        
        approveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        approveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        approveButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        approveButton.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signUpScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 1.5)
        signUpScrollView.contentSize.height = self.view.frame.height * 1.5
    }
    
    @objc func handleShowKeyboard(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraintOfButton?.constant = -(keyboardFrame.height + CGFloat(self.keyboardPadding))
        guard let currentY = currentTextField?.frame.origin.y else { return }
        signUpScrollView.contentInset = UIEdgeInsets(top: -currentY + 36 , left: 0, bottom: 0, right: 0)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    @objc func handleHideKeyboard(notification: NSNotification) {
        
        bottomConstraintOfButton?.constant = CGFloat(-self.keyboardPadding)
        signUpScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        signUpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc private func confirmButtonDidTap() {
        loadingIndicator.activateIndicatorView()
        guard let email = inputEmailTextField.text,
            let password = inputPasswordTextField.text,
            let name = inputNameTextField.text else {
                assertionFailure("text error")
                return
        }
        serverAuth.signUp(email: email,
                          password: password) { (result) in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "회원가입 오류",
                                                  message: "회원가입에 실패하였습니다.",
                                                  preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.loadingIndicator.deactivateIndicatorView()
                    self.present(alert, animated: false, completion: nil)
                }
            case .success:
                guard let email = UserDefaults.standard.string(forKey: "userId"),
                    let uid = UserDefaults.standard.string(forKey: "uid") else {
                        assertionFailure("fetching uid from UserDefault failure")
                        return
                }
                let userData = UserData(uid: uid, description: "", nickName: name, email: email, artworks: [:])
                let user = [uid: userData]
                self.serverDatabase.write(path: "root/users", data: user, method: .patch, headers: [:]){ (result, response) in
                    switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "회원가입 오류",
                                                          message: "회원가입에 실패하였습니다.",
                                                          preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            self.loadingIndicator.deactivateIndicatorView()
                            self.present(alert, animated: false, completion: nil)
                        }
                    case .success:
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: false)
                        }
                    }
                }
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentTextField?.resignFirstResponder()
        currentTextField = nil
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    private func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        // 튜플 이용해서 안내사항 보여줄지 고민중입니다
        if textField == inputEmailTextField {
            return (text.isValidEmail(), "유효한 이메일이 아닙니다.")
        } else if textField == inputPasswordTextField {
            return (text.count >= 6, "비밀번호가 6자 이상이어야 합니다.")
        } else {
            return (!text.isEmpty, "정보가 더 필요합니다")
        }
    }
    
    @objc private func textDidChange(_ notification: Notification) {
        var isValid = true
        
        for textField in textFields {
            let (valid, _) = validate(textField)
            
            guard valid else {
                isValid = false
                approveButton.backgroundColor = .lightGray
                fixedConfirmLabel.text = "아직 정보가 더 필요합니다"
                fixedConfirmLabel.textColor = .red
                return
            }
        }
        approveButton.isEnabled = isValid
        approveButton.backgroundColor = UIColor(named: "keyColor")
        fixedConfirmLabel.text = "준비가 완료되었습니다."
        fixedConfirmLabel.textColor = UIColor(named: "keyColor")
    }
}
//이후 Extension 모아두는 부분에 통합예정
extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
