//
//  EMSetNameViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/7/10.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate

typealias DidUpdateNicknameCallBack = (_ results: String) -> Void

class EMSetNameViewController: UIViewController, UITextFieldDelegate {

    var nicknamcDidUpdateCallBack: DidUpdateNicknameCallBack?
    var myName = ""

    @IBOutlet weak var nicknameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField?.text = myName
    }

    func setup(callBack updatedNicknameCallBack: @escaping DidUpdateNicknameCallBack) {
        nicknamcDidUpdateCallBack = updatedNicknameCallBack
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.characters.count == 0 {
            showAlert("请设置昵称")
            return true
        }
        updateMyName(newName: textField.text!)
        return true
    }
    
    func updateMyName(newName: String) {
        myName = newName

        EMUserProfileManager.sharedInstance.updateUserProfileInBackground(param: [kPARSE_HXUSER_NICKNAME:newName]) { (success, error) -> Void in }
        EMClient.shared().updatePushNotifiationDisplayName(newName) { (displayName, error) in
        }
        
        if nicknamcDidUpdateCallBack != nil {
            nicknamcDidUpdateCallBack!(newName)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
