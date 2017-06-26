//
//  TextfieldTableViewCell.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/18/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class TextfieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textfield: UITextField!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textfield.delegate = self
        textfield.returnKeyType = .done
        textfield.placeholder = NSLocalizedString("Please enter a notification display name", comment: "Please enter a notification display name")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let options = EMClient.shared().pushOptions
        if textfield.text != "" && textfield.text != options?.displayName {
           options?.displayName = textfield.text
            EMClient.shared().updatePushNotificationOptionsToServer(completion: { (error) in
                if error != nil {
                    let alert = UIAlertController(title: NSLocalizedString("error.save", comment: "Failed to save"), message: error?.errorDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kNotification_displayNameUpdated"), object: nil)
                }
            })
        }
        
        return true
    }
}
