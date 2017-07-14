//
//  EMPushNotificationViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/7/7.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import MBProgressHUD

class EMPushNotificationViewController: UITableViewController {
    
    
    @IBOutlet weak var detailSwitch: UISwitch!
    @IBOutlet weak var doNotDisturbSwitch: UISwitch!
    @IBOutlet weak var systemNotificationTypes: UILabel!
    
    var pushDisplayStyle = EMPushDisplayStyleSimpleBanner
    var noDisturbStatus = EMPushNoDisturbStatusClose
    var pushNickname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadPushOptions()
        NotificationCenter.default.addObserver(self, selector: #selector(setupSystemNotificationType), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
 
    func setupSystemNotificationType() {
        systemNotificationTypes.text = isAllowNotification() ? "Enable" : "Disable"
    }
    
    func loadPushOptions() {
        MBProgressHUD.showAdded(to: view, animated: true)
        weak var weakSelf = self
        EMClient.shared().getPushNotificationOptionsFromServer { (aOptions, error) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            if error == nil {
                weakSelf?.updatePushOption(aOptions!)
            } else {
                weakSelf?.showHub(inView: (weakSelf?.view)!, "Get push status failed")
            }
        }
    }
    
    func updatePushOption(_ options: EMPushOptions) {
        pushDisplayStyle = options.displayStyle
        noDisturbStatus = options.noDisturbStatus
        pushNickname = options.displayName
        
        detailSwitch.setOn(pushDisplayStyle == EMPushDisplayStyleSimpleBanner ? false : true , animated: false)
        doNotDisturbSwitch.setOn(noDisturbStatus == EMPushNoDisturbStatusClose ? false: true , animated: false)
    }
    
    func isAllowNotification() -> Bool {
        let settings = UIApplication.shared.currentUserNotificationSettings
        if settings?.types != UIUserNotificationType.init(rawValue: 0) {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let settingsURL = URL.init(string: UIApplicationOpenSettingsURLString)
            if UIApplication.shared.canOpenURL(settingsURL!) {
                UIApplication.shared.openURL(settingsURL!)
            }
        }
    }
    
    @IBAction func detailSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            pushDisplayStyle = EMPushDisplayStyleMessageSummary
        }else {
            pushDisplayStyle = EMPushDisplayStyleSimpleBanner
        }
        
        let pushOptions = EMClient.shared().pushOptions
        pushOptions?.displayStyle = pushDisplayStyle
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        weak var weakSelf = self
        EMClient.shared().updatePushNotificationOptionsToServer { (error) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            if error != nil {
                if pushOptions?.displayStyle == EMPushDisplayStyleMessageSummary {
                    pushOptions?.displayStyle = EMPushDisplayStyleSimpleBanner
                }else {
                    pushOptions?.displayStyle = EMPushDisplayStyleMessageSummary
                }
                
                sender.setOn(!sender.isOn, animated: true)
                weakSelf?.showAlert("Modify push displayStyle failed")
            }
        }
    }
    
    @IBAction func doNotDisturbSwitchAction(_ sender: UISwitch) {
        let pushOptions = EMClient.shared().pushOptions
        if sender.isOn {
            noDisturbStatus = EMPushNoDisturbStatusDay
            pushOptions?.noDisturbingStartH = 0
            pushOptions?.noDisturbingEndH = 24
        }else {
            noDisturbStatus = EMPushNoDisturbStatusClose
        }
        

        pushOptions?.noDisturbStatus = noDisturbStatus
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        weak var weakSelf = self
        EMClient.shared().updatePushNotificationOptionsToServer { (error) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            if error != nil {
                if pushOptions?.noDisturbStatus == EMPushNoDisturbStatusDay {
                    pushOptions?.noDisturbStatus = EMPushNoDisturbStatusClose
                }else {
                    pushOptions?.noDisturbStatus = EMPushNoDisturbStatusDay
                }
                
                sender.setOn(!sender.isOn, animated: true)
                weakSelf?.showAlert("Modify push displayStyle failed")
            }
        }

    }
}
