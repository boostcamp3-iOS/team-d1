
//
//  SignIViewController.swift
//  BeBrav
//
//  Created by bumslap on 15/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    private let serverAuth: FirebaseAuthService
    
    init(serverAuth: FirebaseAuthService) {
        self.serverAuth = serverAuth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var textFields: [UITextField] = []
    private var bottomConstraintOfButton: NSLayoutConstraint?
    private var currentTextField: UITextField?
    
    private let keyboardPadding = 16
    private let minPasswordLength = 6
    
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
        return textField
    }()
    
    private let fixedEmailUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "이메일 주소를 입력해주세요"
        return label
    }()
    
    private let inputPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 36)
        textField.clearButtonMode = .whileEditing
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호"
        return textField
    }()
    
    private let fixedPasswordUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "비밀번호를 입력해주세요"
        return label
    }()
    
    private let approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.setTitle("로그인", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        inputEmailTextField.delegate = self
        inputPasswordTextField.delegate = self
        textFields = [ inputPasswordTextField,
                       inputEmailTextField
        ]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "가입하기", style: .plain, target: self, action: #selector(signUpButtonDidTap))
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyboard), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyboard), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        
    }
    
    func setLayout() {
        
        navigationItem.title = "로그인"
        
        view.addSubview(signUpScrollView)
        
        signUpScrollView.addSubview(fixedEmailUpperLabel)
        signUpScrollView.addSubview(inputEmailTextField)
        
        signUpScrollView.addSubview(fixedPasswordUpperLabel)
        signUpScrollView.addSubview(inputPasswordTextField)
        
        signUpScrollView.addSubview(approveButton)
        
        signUpScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        signUpScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        signUpScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        signUpScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        signUpScrollView.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        loadingIndicator.deactivateIndicatorView()
        
        fixedEmailUpperLabel.topAnchor.constraint(equalTo: signUpScrollView.topAnchor, constant: 8).isActive = true
        fixedEmailUpperLabel.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        
        inputEmailTextField.topAnchor.constraint(equalTo: fixedEmailUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputEmailTextField.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        inputEmailTextField.widthAnchor.constraint(equalTo: signUpScrollView.widthAnchor, multiplier: 0.9).isActive = true
        
        fixedPasswordUpperLabel.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor, constant: 16).isActive = true
        fixedPasswordUpperLabel.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        
        
        inputPasswordTextField.topAnchor.constraint(equalTo: fixedPasswordUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputPasswordTextField.leadingAnchor.constraint(equalTo: signUpScrollView.leadingAnchor, constant: 16).isActive = true
        inputPasswordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        inputPasswordTextField.trailingAnchor.constraint(equalTo: signUpScrollView.trailingAnchor, constant: 0).isActive = true
        
        bottomConstraintOfButton = NSLayoutConstraint(item: approveButton, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -16)
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
        bottomConstraintOfButton?.constant = -(keyboardFrame.height + CGFloat(keyboardPadding))
        guard let currentY = currentTextField?.frame.origin.y else { return }
        signUpScrollView.contentInset = UIEdgeInsets(top: -currentY + 42 , left: 0, bottom: 0, right: 0)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleHideKeyboard(notification: NSNotification) {
        bottomConstraintOfButton?.constant = CGFloat(-self.keyboardPadding)
        signUpScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        signUpScrollView.setContentOffset(CGPoint(x: 0, y: -100), animated: true)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func signUpButtonDidTap() {
        let container = NetworkDependencyContainer()
        let signUpPageViewController = SignUpViewController(serverAuth: container.buildServerAuth(), serverDatabase: container.buildServerDatabase())
        navigationController?.pushViewController(signUpPageViewController, animated: false)
    }
    
    @objc func confirmButtonDidTap() {
        loadingIndicator.activateIndicatorView()
        guard let email = inputEmailTextField.text,
            let password = inputPasswordTextField.text else { return }
        serverAuth.signIn(email: email, password: password) { (result) in
            switch result {
            case .failure:
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "로그인 오류",
                                                  message: "아이디 / 비밀번호를 확인해주세요",
                                                  preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(action)
                    self.loadingIndicator.deactivateIndicatorView()
                    self.present(alert, animated: false, completion: nil)
                    
                }
            case .success:
                DispatchQueue.main.async {
                    self.loadingIndicator.deactivateIndicatorView()
                    let imageLoader = ImageLoader(session: URLSession.shared, diskCache: DiskCache(), memoryCache: MemoryCache())
                    let serverDatabase = NetworkDependencyContainer().buildServerDatabase()
                    
                    let mainViewController = PaginatingCollectionViewController(serverDatabase: serverDatabase, imageLoader: imageLoader)
        
                    let newRootViewController = UINavigationController(rootViewController: mainViewController)
                    UIApplication.shared.keyWindow?.rootViewController = newRootViewController
                }
                
            }
        }
        //TODO: 이후 메인뷰로 이동하는 로직 추가
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // currentTextField 이용한 로직 구현 가능성 있음
        return true
    }
    
    private func validate(_ textField: UITextField) -> (Bool) {
        guard let text = textField.text else {
            return false
        }
        if textField == inputEmailTextField {
            return text.isValidEmail()
        } else {
            return text.count >= minPasswordLength
        }
    }
    
    
    @objc private func textDidChange(_ notification: Notification) {
        var isValid = true
        for textField in textFields {
            let valid = validate(textField)
            
            guard valid else {
                isValid = false
                approveButton.backgroundColor = .lightGray
                return
            }
        }
        approveButton.isEnabled = isValid
        approveButton.backgroundColor = UIColor(named: "keyColor")
    }
    
}
