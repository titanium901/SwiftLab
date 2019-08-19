//
//  LoginViewController.swift
//  RestorantRating
//
//  Created by Yury Popov on 22/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication

// Конфигурация связки ключей
struct KeychainConfiguration {
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {
    
//MARK: - IBOutlet

    @IBOutlet var usernameTextField: UITextField! {
        didSet {
            usernameTextField.tintColor = UIColor.lightGray
            usernameTextField.setIcon(UIImage(named: "man")!)
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.tintColor = UIColor.lightGray
            passwordTextField.setIcon(UIImage(named: "key")!)
        }
    }
    
    @IBOutlet var createInfoLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var touchIDButton: UIButton!
    
//MARK: - Properties
    
    var passwordItems: [KeychainPasswordItem] = []
//    let createLoginButtonTag = 0 // Метка для кнопки создать
//    let loginButtonTag = 1 // Метка для кнопки Вход
    let touchMe = TouchIDAuth()
    var currentType = LAContext().biometricType
    
//MARK: - override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToRest", sender: nil)
            }
        }
        
    }

//MARK: - custom Methods
    
    func setupUI() {
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
        usernameTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if hasLogin {
            createInfoLabel.isHidden = true
        } else {
            createInfoLabel.isHidden = false
        }
        if let storedUserName = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUserName
        }
        
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy() || !hasLogin
        
        switch currentType {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "face"), for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "touch"), for: .normal)
        }
        
    }
    
//    func checkLogin(username: String, password: String) -> Bool {
//        guard username == UserDefaults.standard.value(forKey: "username") as? String else { return false }
//
//        do {
//            let passwordItem = KeychainPasswordItem.init(service: KeychainConfiguration.serviceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
//            let keychainPassword = try passwordItem.readPassword()
//            return password == keychainPassword
//        } catch {
//            fatalError("Ошика чтения из свзяки ключей: \(error)")
//        }
//
//    }
    
    func createUserKeyChain(email: String, password: String) {
        let newAccountName = email
        let newPassword = password
        guard !newAccountName.isEmpty && !newPassword.isEmpty else {
            let alertView = UIAlertController(title: "Login Problem", message: "Username or password is not filled", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Еще раз", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true)
            return
        }
        
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey {
            UserDefaults.standard.set(newAccountName, forKey: "username")
        }
        
        //Создаем новый элемент в связке ключей
        do {
            //Создаем новый элемент в Связке ключей с именем пользователя
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: newAccountName, accessGroup: KeychainConfiguration.accessGroup)
            // Сохранить пароль для нового элемента
            try passwordItem.savePassword(newPassword)
        } catch {
            fatalError("Ошибка обновления Связки ключей: \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
    }

    
//MARK: - IBAction
    
    @IBAction func loginAction(_ sender: AnyObject) {
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                self.errorLoginAlert(error: error.localizedDescription)
                return
            }
            if result != nil {
                self.performSegue(withIdentifier: "LoginToRest", sender: nil)
            }
        }
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Register", message: "Check in", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            //Получили email и пароль, теперь можем создать пользователя Firebase
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (result, error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .weakPassword:
                            print("Enter a more complex password!")
                        default:
                            print("Error")
                        }
                    }
                    return
                }
                if result != nil {
                    result?.user.sendEmailVerification(completion: { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            
                        }
                    })
                }
                
            })
            
            self.createUserKeyChain(email: emailField.text!, password: passwordField.text!)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func touchIDLoginAction(_ sender: UIButton) {
        //метод с hackingwithswift
        let laContext = LAContext()
        var error: NSError?
        let biometricsPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        if (laContext.canEvaluatePolicy(biometricsPolicy, error: &error)) {
            
            if let laError = error {
                print("laError - \(laError)")
                return
            }
            
            var localizedReason = "Unlock device"
            if #available(iOS 11.0, *) {
                switch laContext.biometryType {
                case .faceID: localizedReason = "Unlock using Face ID"; print("FaceId support")
                case .touchID: localizedReason = "Unlock using Touch ID"; print("TouchId support")
                case .none: print("No Biometric support")
                @unknown default:
                    fatalError()
                }
            } else {
                // Fallback on earlier versions
            }
            
            
            laContext.evaluatePolicy(biometricsPolicy, localizedReason: localizedReason, reply: { (isSuccess, error) in
                
                DispatchQueue.main.async(execute: {
                    
                    if let laError = error {
                        print("laError - \(laError)")
                    } else {
                        if isSuccess {
                            print("sucess")
                            self.authFireBase()
                        } else {
                            print("failure")
                            self.usernameTextField.resignFirstResponder()

                        }
                    }
                    
                })
            })
        }
        
        //с кодом ниже почему то не хотел работать face id каждый раз
        
        
//        touchMe.authenticateUser { message in
//            if let message = message {
//                //если сообщение не nil, то показать оповещение
//                let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "Damn it!", style: .default, handler: nil)
//                alertView.addAction(okAction)
//                self.present(alertView, animated: true)
//            } else {
//                //нет сообщений, значит аутенфикация прошла успешно
//                guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
//                var password = String()
//                do {
//                    let passwordItem = KeychainPasswordItem.init(service: KeychainConfiguration.serviceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
//                    let keychainPassword = try passwordItem.readPassword()
//                    password = keychainPassword
//
//                    Auth.auth().signIn(withEmail: username, password: password) { (result, error) in
//                        if let error = error {
//                            print(error.localizedDescription)
//                            self.errorLoginAlert(error: error.localizedDescription)
//                            return
//                        }
//                        if result != nil {
//                            self.performSegue(withIdentifier: "LoginToRest", sender: nil)
//                        }
//                    }
//
//                } catch {
//                    fatalError("Ошика чтения из свзяки ключей: \(error)")
//                }
//
//
//
//            }
//
//        }
    }
    
    func authFireBase() {
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
        var password = String()
        do {
            let passwordItem = KeychainPasswordItem.init(service: KeychainConfiguration.serviceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            password = keychainPassword
            
            Auth.auth().signIn(withEmail: username, password: password) { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.errorLoginAlert(error: error.localizedDescription)
                    return
                }
                if result != nil {
                    self.performSegue(withIdentifier: "LoginToRest", sender: nil)
                }
            }
            
        } catch {
            fatalError("Ошика чтения из свзяки ключей: \(error)")
        }
        
        
    }
    
    func errorLoginAlert(error: String) {
        let ac = UIAlertController(title: "Oops...", message: error, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Ok", style: .default, handler: nil)
        ac.addAction(okBtn)
        present(ac, animated: true)
    }
    
}

//MARK: extension UITextField

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 40, height: 40))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 50, height: 50))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}

//MARK: extension LAContext
//Дублируется код, нужно бы убрать

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Capture these recoverable error thru Crashlytics
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                fatalError()
                
            }
        } else {
            return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}
