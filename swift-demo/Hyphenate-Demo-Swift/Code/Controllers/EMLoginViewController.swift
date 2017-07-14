//
//  EMLoginViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/13.
//  Copyright 2017 dujiepeng. All rights reserved.
//

import UIKit
import MBProgressHUD
import Hyphenate

class EMLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var loginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setupUI()
        setupForDismissKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(noti:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)  
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent  
    }
    
    func setupUI () {
        usernameTextField.delegate = self  
        usernameTextField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 15, height: usernameTextField.height()))  
        usernameTextField.leftViewMode = UITextFieldViewMode.always  
        
        passwordTextField.delegate = self  
        passwordTextField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 15, height: passwordTextField.height()))  
        passwordTextField.leftViewMode = UITextFieldViewMode.always  
        
        loginButton.top(top: kScreenHeight - loginButton.height())  
        loginButton.width(width: kScreenWidth)  
        
        signupButton.top(top: kScreenHeight - signupButton.height())  
        signupButton.width(width: kScreenWidth)  
    }
    
    func setBackgroundColor () {
        let gradient = CAGradientLayer.init()  
        gradient.frame = UIScreen.main.bounds  
        gradient.colors =  [LaunchTopColor.cgColor, LaunchBottomColor.cgColor]  
        gradient.startPoint = CGPoint.init(x: 0.0, y: 0.0)  
        gradient.endPoint = CGPoint.init(x: 0.0, y: 1.0)  
        view.layer.insertSublayer(gradient, at: 0)  
    }
    
    @IBAction func doLogin(_ sender: UIButton?) {
        if _isEmpty() {
            return  
        }

        MBProgressHUD.showAdded(to: view, animated: true)  
        weak var weakSelf = self
        EMClient.shared().login(withUsername: usernameTextField.text, password: passwordTextField.text) { (username, error) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            
            if error == nil {
                EMClient.shared().options.isAutoLogin = true  
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: true))  
            } else {
                var alertStr = ""  
                switch error!.code {
                case EMErrorUserNotFound:
                    alertStr = error!.errorDescription  
                    break
                case EMErrorNetworkUnavailable:
                    alertStr = error!.errorDescription  
                    break
                case EMErrorServerNotReachable:
                    alertStr = error!.errorDescription  
                    break
                case EMErrorUserAuthenticationFailed:
                    alertStr = error!.errorDescription  
                    break
                case EMErrorServerTimeout:
                    alertStr = error!.errorDescription  
                    break
                default:
                    alertStr = error!.errorDescription  
                    break
                }
                
                let alertView = UIAlertView.init(title: nil, message: alertStr, delegate: nil, cancelButtonTitle: "okay")
                alertView.show()  
            }
        }  
    }
    
    @IBAction func doSignUp(_ sender: UIButton?) {
        if _isEmpty() {
            return  
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)  
        weak var weakSelf = self
        EMClient.shared().register(withUsername: usernameTextField.text, password: passwordTextField.text) { (username, error) in
            var alertStr = ""  
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            if error == nil {
                alertStr = "Registration Succeed"
            } else {
                alertStr = "Registration Failed"
                switch error!.code {
                case EMErrorServerNotReachable:
                    alertStr = error!.errorDescription  
                    break  
                case EMErrorNetworkUnavailable:
                    alertStr = error!.errorDescription  
                    break  
                case EMErrorServerTimeout:
                    alertStr = error!.errorDescription  
                    break  
                case EMErrorUserAlreadyExist:
                    alertStr = error!.errorDescription  
                    break  
                default:
                    alertStr = error!.errorDescription  
                    break  
                }
                
                let alertView = UIAlertView.init(title: nil, message: alertStr, delegate: nil, cancelButtonTitle: "okay")
                alertView.show()  
            }
        }  
    }
    
    @IBAction func doChangeState(_ sender: UIButton) {
        isEditing = true  
        if signupButton.isHidden == true {
            loginButton.isHidden = true  
            signupButton.isHidden = false  
            changeButton.setTitle("Log in", for: UIControlState.normal)
            tipLabel.text = "Have an account?"  
        } else {
            loginButton.isHidden = false  
            signupButton.isHidden = true  
            changeButton.setTitle("Sign up", for: UIControlState.normal)
            tipLabel.text = "Yay! New to Hyphenate?"  
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.text = ""  
        }
        
        return true  
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()  
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()  
            if signupButton.isHidden == true {
                doLogin(nil)
            }else {
                doSignUp(nil)
            }
        }
        
        return true  
    }
    
    // MARK: - private
    
    fileprivate func _isEmpty() -> Bool {
        
        var ret = false  
        let username = usernameTextField.text  
        let password = passwordTextField.text  
        
        if (username?.characters.count)! == 0 || (password?.characters.count)! == 0 {
            ret = true  
            let alertView = UIAlertView.init(title: "reminder", message: "please enter username and password", delegate: nil, cancelButtonTitle: "okay")
            alertView.show()  
        }
        
        return ret  
    }
    
    // MARK: - notification
    func keyboardWillChangeFrame(noti: NSNotification) {
        let userInfo = (noti.userInfo as! Dictionary<String, NSValue>)  
        let beginValue = userInfo["UIKeyboardFrameBeginUserInfoKey"]!  
        let endValue = userInfo["UIKeyboardFrameEndUserInfoKey"]!  
        
        var beginRect = CGRect()  
        var endRect = CGRect()  
        beginValue.getValue(&beginRect)  
        endValue.getValue(&endRect)  
        
        var btnFrame = CGRect()  
        var top: CGFloat = 0  
        
        if signupButton.isHidden {
            btnFrame = loginButton.frame  
        } else {
            btnFrame = signupButton.frame  
        }
        
        if endRect.origin.y == view.height() {
            btnFrame.origin.y = kScreenHeight - btnFrame.size.height  
        } else if (beginRect.origin.y == view.height()) {
            btnFrame.origin.y = kScreenHeight - btnFrame.size.height - endRect.size.height + 100  
            top = -100  
        } else {
            btnFrame.origin.y = kScreenHeight - btnFrame.size.height - endRect.size.height + 100  
            top = -100  
        }
        
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3) {
            UIApplication.shared.keyWindow?.top(top: top)  
            weakSelf?.loginButton.frame = btnFrame
            weakSelf?.signupButton.frame = btnFrame
        }  
        
    }
}
