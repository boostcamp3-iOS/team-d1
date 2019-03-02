
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
    
    private let loadingIndicator: LoadingIndicatorView = {
        let indicator = LoadingIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.noticeLabel.text = "verifying".localized
        return indicator
    }()
    
    private let inputEmailTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 36)
        textField.clearButtonMode = .whileEditing
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.textColor = .white
        textField.becomeFirstResponder()
        textField.attributedPlaceholder = NSAttributedString(string:"email".localized,
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedEmailUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "enterEmail".localized
        label.textColor = .white
        return label
    }()
    
    private let inputPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 36)
        textField.clearButtonMode = .whileEditing
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.textColor = .white
        textField.placeholder = "Password".localized
        textField.attributedPlaceholder = NSAttributedString(string:"Password".localized,
                                                             attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.3)])
        return textField
    }()
    
    private let fixedPasswordUpperLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "enterPassword".localized
        label.textColor = .white
        return label
    }()
    
    private let signUpTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        var attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0),
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.underlineStyle : 1]
        var attributedString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string:"you don't have an account yet?".localized, attributes:attrs)
        attributedString.append(buttonTitleStr)
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private let approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitle("signIn".localized, for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        return button
    }()
    
    private let lookAroundButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitle("tour".localized, for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        guard let window = UIApplication.shared.keyWindow else { return }
        toppading = window.safeAreaInsets.top
        inputEmailTextField.delegate = self
        inputPasswordTextField.delegate = self
        textFields = [
            inputPasswordTextField,
            inputEmailTextField]
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyboard), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyboard), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signUpScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 1.1)
        
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
    
    func setLayout() {
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(signUpScrollView)
        
        signUpScrollView.addSubview(fixedEmailUpperLabel)
        signUpScrollView.addSubview(inputEmailTextField)
        
        signUpScrollView.addSubview(fixedPasswordUpperLabel)
        signUpScrollView.addSubview(inputPasswordTextField)
        //signUpScrollView.addSubview(lookAroundButton)
        signUpScrollView.addSubview(approveButton)
        signUpScrollView.addSubview(loadingIndicator)
        
        signUpScrollView.addSubview(signUpTextButton)
        
        signUpScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        signUpScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        signUpScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        signUpScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        loadingIndicator.deactivateIndicatorView()
        
        fixedEmailUpperLabel.topAnchor.constraint(equalTo: signUpScrollView.topAnchor, constant: 58).isActive = true
        fixedEmailUpperLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        fixedEmailUpperLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        inputEmailTextField.topAnchor.constraint(equalTo: fixedEmailUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        inputEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        fixedPasswordUpperLabel.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor, constant: 4).isActive = true
        fixedPasswordUpperLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        fixedPasswordUpperLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        inputPasswordTextField.topAnchor.constraint(equalTo: fixedPasswordUpperLabel.bottomAnchor, constant: 16).isActive = true
        inputPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        inputPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        signUpTextButton.addTarget(self, action: #selector(signUpTextButtonDidTap), for: .touchUpInside)
        signUpTextButton.topAnchor.constraint(equalTo: inputPasswordTextField.bottomAnchor, constant: 16).isActive = true
        signUpTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        bottomConstraintOfButton = NSLayoutConstraint(item: approveButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.01, constant: 0)
        bottomConstraintOfButton?.isActive = true
        
        approveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        approveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        approveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        approveButton.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        
        /* TODO: 이후 구현
        lookAroundButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lookAroundButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        lookAroundButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        lookAroundButton.bottomAnchor.constraint(equalTo: approveButton.topAnchor, constant: -8).isActive = true
        lookAroundButton.addTarget(self, action: #selector(lookAroundButtonDidTap), for: .touchUpInside)
 */
 }
    
    
    @objc func signUpTextButtonDidTap() {
        let container = NetworkDependencyContainer()
        let signUpPageViewController = SignUpViewController(serverAuth: container.buildServerAuth(), serverDatabase: container.buildServerDatabase())
        present(signUpPageViewController, animated: false, completion: nil)
    }
    @objc func handleShowKeyboard(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        bottomConstraintOfButton?.constant = -(keyboardFrame.height + CGFloat(keyboardPadding))
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
    
    @objc func confirmButtonDidTap() {
        loadingIndicator.activateIndicatorView()
        guard let email = inputEmailTextField.text,
            let password = inputPasswordTextField.text else { return }
        serverAuth.signIn(email: email, password: password) { (result) in
            switch result {
            case .failure:
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "signInError".localized,
                                                  message: "signInErrorMessage".localized,
                                                  preferredStyle: .alert)
                    let action = UIAlertAction(title: "done".localized, style: .default, handler: nil)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
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
