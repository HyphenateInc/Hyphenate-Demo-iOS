//
//  SignUpViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/12/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import Hyphenate

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextfield: HyphenateTextField!
    @IBOutlet weak var passwordTextfield: HyphenateTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        let loginButton:UIButton = UIButton(type: .custom)
        loginButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
        loginButton.backgroundColor = UIColor.hiPrimary()
        loginButton.setTitle("Sign Up", for: .normal)
        
        loginButton.addTarget(self, action: #selector(SignUpViewController.signupAction(_:)), for: .touchUpInside)
        usernameTextfield.inputAccessoryView = loginButton
        passwordTextfield.inputAccessoryView = loginButton
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }

    func dismissKeyboard(){
        usernameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }

    @IBAction func signupAction(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        EMClient.shared().register(withUsername: usernameTextfield.text, password: passwordTextfield.text) { (userID, error) in
            
            if ((error) != nil) {
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title:"Registration Failure", message: error?.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                EMClient.shared().login(withUsername: self.usernameTextfield.text, password: self.passwordTextfield.text, completion: { (userID, error) in
                    if ((error) != nil) {
                        let alert = UIAlertController(title:"Login Failure", message: error?.errorDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    } else if EMClient.shared().isLoggedIn {
                        EMClient.shared().options.isAutoLogin = true
                        let mainVC = MainViewController()
                        HyphenateMessengerHelper.sharedInstance.mainVC = mainVC
                        self.navigationController?.pushViewController(mainVC, animated: true)
                    }
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextfield {
            usernameTextfield.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
        } else {
            signupAction(self)
        }
        return true
    }
}
