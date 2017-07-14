//
//  EMAddContactViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/28.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import MBProgressHUD

class EMAddContactViewController: UIViewController, UITextFieldDelegate {
    
    private var _addViewY: CGFloat = 0
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var addView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTextField()
        setupForDismissKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _addViewY = addView.frame.origin.y
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func setupNavBar() {
        title = "Add Contact"
        let cancelBtn = UIButton(type: UIButtonType.custom)
        cancelBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        cancelBtn.setTitleColor(KermitGreenTwoColor, for: UIControlState.normal)
        cancelBtn.setTitleColor(KermitGreenTwoColor, for: UIControlState.highlighted)
        cancelBtn.setTitle("Cancel", for: UIControlState.normal)
        cancelBtn.setTitle("Cancel", for: UIControlState.highlighted)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        cancelBtn.addTarget(self, action: #selector(cancelAddContact), for: UIControlEvents.touchUpInside)
        
        let rightBar = UIBarButtonItem(customView: cancelBtn)
        navigationItem.rightBarButtonItem = rightBar
    }
    
    func setupTextField() {
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 28, height: 13))
        let leftImage = UIImageView(frame: CGRect(x: 15, y: 0, width: 13, height: 13))
        leftImage.image = UIImage(named:"Icon_Search.png")
        leftView.addSubview(leftImage)
        textField.leftView = leftView
        textField.leftViewMode = UITextFieldViewMode.always
        textField.placeholder = "Enter Hyphenate ID"
        textField.clipsToBounds = true
        textField.layer.borderColor = CoolGrayColor.cgColor
        
        textField.returnKeyType = UIReturnKeyType.search
    }
    
    func cancelAddContact() {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func isContactAlready(username: String) -> Bool {
        let contacts = EMClient.shared().contactManager.getContacts() as! [String]
        for contactName in contacts {
            if contactName ==  username{
                return true
            }
        }
        
        return false
    }
    
    func addContact() {
        let contactName = textField.text
        if contactName?.characters.count == 0 {
            showAlert("No input contact name")
            return
        }
        
        if isContactAlready(username: contactName!) {
            showAlert("This contact has been added")
            return
        }
        
        if contactName == EMClient.shared().currentUsername {
            showAlert("Not allowed to send their own friends to apply for")
            return
        }
        
        sendRequest(contactName!)
    }
    
    func sendRequest(_ contactName: String) {
        let requestMessage = EMClient.shared().currentUsername + " add you as a friend"
        MBProgressHUD.showAdded(to: navigationController?.view, animated: true)
        weak var weakSelf = self
        EMClient.shared().contactManager.addContact(contactName, message: requestMessage) { (username, error) in
            MBProgressHUD.hideAllHUDs(for: weakSelf?.navigationController?.view, animated: true)
            if error == nil {
                weakSelf?.addButton.isUserInteractionEnabled = false
                weakSelf?.textField.text = ""
                weakSelf?.showAlert("You request has been sent.")
            }else {
                weakSelf?.showAlert((error?.errorDescription)!)
            }
        }
    }
    
    @IBAction func addContactAction(_ sender: UIButton) {
        textField.resignFirstResponder()
        addContact()
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addContact()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func keyboardWillChangeFrame(noti: Notification) {
        let userInfo = (noti.userInfo as! Dictionary<String, NSValue>)
        let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]!.cgRectValue
        
        var addFrame = addView.frame
        let bottomOffset = addFrame.origin.y + addFrame.size.height + 64
        if bottomOffset > endFrame.origin.y {
           addFrame.origin.y = addFrame.origin.y - (10 + bottomOffset - endFrame.origin.y)
        } else if endFrame.origin.y >= kScreenHeight {
            addFrame.origin.y = _addViewY
        }
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25) { 
            weakSelf?.addView.frame = addFrame
        }
    }
}
