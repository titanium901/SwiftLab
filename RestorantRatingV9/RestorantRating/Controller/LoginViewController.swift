//
//  LoginViewController.swift
//  RestorantRating
//
//  Created by Yury Popov on 22/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit
import Firebase

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
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToRest", sender: nil)
            }
        }
        
    }
    
    func setupUI() {
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
        usernameTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        
    }
    
    
    

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
        
    }
    
    func errorLoginAlert(error: String) {
        let ac = UIAlertController(title: "Oops...", message: error, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Ok", style: .default, handler: nil)
        ac.addAction(okBtn)
        present(ac, animated: true)
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
