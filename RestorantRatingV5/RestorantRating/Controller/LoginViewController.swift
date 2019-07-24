//
//  LoginViewController.swift
//  RestorantRating
//
//  Created by Yury Popov on 22/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

// Конфигурация связки ключей
struct KeychainConfiguration {
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {

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
    
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0 // Метка для кнопки создать
    let loginButtonTag = 1 // Метка для кнопки Вход
    let touchMe = TouchIDAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if hasLogin {
            loginButton.setTitle("Log In", for: .normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.isHidden = true
        } else {
            loginButton.setTitle("Create", for: .normal)
            loginButton.tag = createLoginButtonTag
            createInfoLabel.isHidden = false
        }
        if let storedUserName = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUserName
        }
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy() || !hasLogin
        setupUI()
        
    }
    
    func setupUI() {
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
        
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        guard username == UserDefaults.standard.value(forKey: "username") as? String else { return false }
        
        do {
            let passwordItem = KeychainPasswordItem.init(service: KeychainConfiguration.serviceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        } catch {
            fatalError("Ошика чтения из свзяки ключей: \(error)")
        }
        
    }
    

    @IBAction func loginAction(_ sender: AnyObject) {
        guard
            let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty && !newPassword.isEmpty else {
                let alertView = UIAlertController(title: "Проблема со входом", message: "Не заполнено имя или пароль", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Еще раз", style: .default, handler: nil)
                alertView.addAction(okAction)
                present(alertView, animated: true)
                return
        }
        
        // Отключить клвавиатуру
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        // Если тэг = createLoginButton, то перейти к созданию нового логина
        if sender.tag == createLoginButtonTag {
            print(#function)
            // Проверяем есть ли LoginKey в UserDefaults. Если нет, то создаем нового пользователя
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
            loginButton.tag = loginButtonTag
            
            performSegue(withIdentifier: "DismissLogin", sender: self)
        } else if sender.tag == loginButtonTag {
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                
                performSegue(withIdentifier: "DismissLogin", sender: self)
            } else {
                // Авторизация не пройдена
                let alertView = UIAlertController(title: "Проблема со входом", message: "Не правильное имя или пароль", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Еще раз", style: .default, handler: nil)
                alertView.addAction(okAction)
                present(alertView, animated: true)
            }
            
        }
    }
    
    @IBAction func touchIDLoginAction(_ sender: UIButton) {
        touchMe.authenticateUser { message in
            if let message = message {
                //если сообщение не nil, то показать оповещение
                let alertView = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Черт побери!", style: .default, handler: nil)
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
            } else {
                //нет сообщений, значит аутенфикация прошла успешно
                self.performSegue(withIdentifier: "DismissLogin", sender: self)
                
            }
            
        }
    }
    
}

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
