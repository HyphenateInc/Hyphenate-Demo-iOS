//
//  FriendRequestViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/4/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class FriendRequestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var inputTextfield: HyphenateTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Contact"
        statusLabel.text = ""
        let rightButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(FriendRequestViewController.cancelAction))
        navigationItem.rightBarButtonItem = rightButtonItem
        navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func addAction(_ sender: AnyObject) {
        addFriendActions()
    }

    func addFriendActions() {
        if inputTextfield.text != "" {
            spinner.startAnimating()
            
            EMClient.shared().contactManager.addContact(inputTextfield.text, message: "\(EMClient.shared().currentUsername) sent you a friend request") { (userName, error) in
                self.spinner.stopAnimating()
                if error != nil {
                    let alert = UIAlertController(title:"Error", message: "Fail sending a friend request, please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addFriendActions()
        return true
    }
}
