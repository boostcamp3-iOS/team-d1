
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
    
    private var currentTextField: UITextField?
    private var textFields: [UITextField] = []
    private var bottomConstraintOfButton: NSLayoutConstraint?
    
    private let keyboardPadding = 16
    private let minPasswordLength = 6
    private var toppading: CGFloat = 0.0
    
    private let signUpScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "logoCaligraphy"))
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
        textField.becomeFirstResponder()
        textField.attributedPlaceholder = NSAttributedString(string:"이메일",
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedEmailUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "이메일"
        label.textColor = .white
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
        textField.textColor = .white
        textField.placeholder = "비밀번호"
        textField.attributedPlaceholder = NSAttributedString(string:"비밀번호",
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedPasswordUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "비밀번호"
        label.textColor = .white
        return label
    }()
    
    private let approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        return button
    }()
    
    private let lookAroundButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitle("둘러보기", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        guard let window = UIApplication.shared.keyWindow else { return }
        toppading = window.safeAreaInsets.top
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signUpScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 1.5)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let emailClearButton = inputEmailTextField.value(forKey: "_clearButton") as? UIButton,
            let passwordClearButton = inputPasswordTextField.value(forKey: "_clearButton") as? UIButton {
            let buttonImage = emailClearButton.currentImage?.withRenderingMode(.alwaysTemplate)
            emailClearButton.setImage(buttonImage, for: .normal)
            emailClearButton.setImage(buttonImage, for: .highlighted)
            emailClearButton.tintColor = .white

            passwordClearButton.setImage(buttonImage, for: .normal)
            passwordClearButton.setImage(buttonImage, for: .highlighted)
            passwordClearButton.tintColor = .white
     
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let window = UIApplication.shared.keyWindow else { return }
        let topPadding = window.safeAreaInsets.top
       
        signUpScrollView.setContentOffset(CGPoint(x: 0, y: logoImageView.frame.maxY - topPadding * 2), animated: true)
        
    }

    
    func setLayout() {
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        navigationItem.title = "로그인"
        let font = UIFont.boldSystemFont(ofSize: 22)
       
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: font,
                                                            NSAttributedString.Key.foregroundColor: UIColor(named: "backgroundColor")
        ]
        
        view.addSubview(signUpScrollView)
        
        signUpScrollView.addSubview(fixedEmailUpperLabel)
        signUpScrollView.addSubview(inputEmailTextField)
        
        signUpScrollView.addSubview(fixedPasswordUpperLabel)
        signUpScrollView.addSubview(inputPasswordTextField)
        signUpScrollView.addSubview(lookAroundButton)
        signUpScrollView.addSubview(approveButton)
        signUpScrollView.addSubview(loadingIndicator)
        signUpScrollView.addSubview(logoImageView)
        
        signUpScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        signUpScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        signUpScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        signUpScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        loadingIndicator.deactivateIndicatorView()
        
        logoImageView.topAnchor.constraint(equalTo: signUpScrollView.topAnchor, constant: 62).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: signUpScrollView.centerXAnchor).isActive = true
        
        fixedEmailUpperLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 42).isActive = true
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
        
        bottomConstraintOfButton = NSLayoutConstraint(item: approveButton, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.01, constant: 0)
        bottomConstraintOfButton?.isActive = true
        
        approveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        approveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        approveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        approveButton.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        
        lookAroundButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lookAroundButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        lookAroundButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        lookAroundButton.bottomAnchor.constraint(equalTo: approveButton.topAnchor, constant: -8).isActive = true
        lookAroundButton.addTarget(self, action: #selector(lookAroundButtonDidTap), for: .touchUpInside)
    }
    
    @objc func handleShowKeyboard(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraintOfButton?.constant = -(keyboardFrame.height + CGFloat(keyboardPadding))
         guard let window = UIApplication.shared.keyWindow else { return }
        let topPadding = window.safeAreaInsets.top
        signUpScrollView.setContentOffset(CGPoint(x: 0, y: logoImageView.frame.maxY - topPadding * 2), animated: true)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleHideKeyboard(notification: NSNotification) {
        bottomConstraintOfButton?.constant = CGFloat(-self.keyboardPadding)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func signUpButtonDidTap() {
        let container = NetworkDependencyContainer()
        let signUpPageViewController = SignUpViewController(serverAuth: container.buildServerAuth(), serverDatabase: container.buildServerDatabase())
        present(signUpPageViewController, animated: true, completion: nil)
    }
    
    @objc func confirmButtonDidTap() {
        loadingIndicator.activateIndicatorView()
        guard let email = inputEmailTextField.text,
            let password = inputPasswordTextField.text else { return }
        serverAuth.signIn(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "로그인 오류",
                                                  message: error.localizedDescription,
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
                    let databaseHandler = DatabaseFactory().buildDatabaseHandler()
                    
                    let mainViewController = PaginatingCollectionViewController(serverDatabase: serverDatabase, imageLoader: imageLoader, databaseHandler: databaseHandler)
                    
                    let newRootViewController = UINavigationController(rootViewController: mainViewController)
                    UIApplication.shared.keyWindow?.rootViewController = newRootViewController
                }
            }
        }
    }

    @objc func lookAroundButtonDidTap() {}
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentTextField?.resignFirstResponder()
        signUpScrollView.setContentOffset(CGPoint(x: 0, y: -toppading), animated: true)
        currentTextField = nil
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        currentTextField?.resignFirstResponder()
    }
    
}
