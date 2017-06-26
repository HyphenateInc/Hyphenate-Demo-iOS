//
//  LoginViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/10/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import Hyphenate

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameTextField: HyphenateTextField!
    @IBOutlet weak var passwordTextField: HyphenateTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    var kbHeight: CGFloat!
    var animated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        
        let loginButton:UIButton = UIButton(type: .custom)
            loginButton.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
            loginButton.backgroundColor = UIColor.hiPrimary()
            loginButton.setTitle("Log In", for: .normal)
       
        loginButton.addTarget(self, action: #selector(LoginViewController.loginAction(_:)), for: .touchUpInside)
        userNameTextField.inputAccessoryView = loginButton
        passwordTextField.inputAccessoryView = loginButton
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismissKeyboard(){
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        
        activityIndicator.startAnimating()
        
        
        EMClient.shared().login(withUsername: userNameTextField.text, password: passwordTextField.text) { (userName : String?, error : EMError?) in
            
            self.activityIndicator.stopAnimating()
            
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
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            userNameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            loginAction(self)
        }
        return true
    }
}
