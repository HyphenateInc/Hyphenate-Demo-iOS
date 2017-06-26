//
//  SwitchTableViewCell.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/1/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var uiswitch: UISwitch!
    @IBOutlet weak var title: UILabel!
   
    var pushDisplayStyle:EMPushDisplayStyle?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiswitch.addTarget(self, action: #selector(switchStateChanged(switchState:)), for: .valueChanged)
    }

    func switchStateChanged(switchState: UISwitch) {
        if title.text == "Enable Push notifications" {
            if switchState.isOn == true {
                let pushSettings = UIUserNotificationSettings(types:[UIUserNotificationType.badge ,UIUserNotificationType.sound ,UIUserNotificationType.alert], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(pushSettings)
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
        
        if title.text == "Show Message Details on Lock Screen" {
            if switchState.isOn == true {
                pushDisplayStyle = EMPushDisplayStyleMessageSummary
            } else {
                pushDisplayStyle = EMPushDisplayStyleSimpleBanner
            }
            
            let options = EMClient.shared().pushOptions
            if pushDisplayStyle != options?.displayStyle {
                options?.displayStyle = pushDisplayStyle!
                EMClient.shared().updatePushNotificationOptionsToServer(completion: { (error) in
                    if error != nil {
                        let alert = UIAlertController(title: NSLocalizedString("error.save", comment: "Failed to save"), message: error?.errorDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }

    }
}
