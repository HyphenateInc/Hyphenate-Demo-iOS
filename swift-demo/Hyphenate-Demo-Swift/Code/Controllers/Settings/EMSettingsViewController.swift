//
//  EMSettingsViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/7/7.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import MBProgressHUD

class EMSettingsViewController: UITableViewController {
    @IBOutlet weak var hyphenateIdLabel: UILabel!
    @IBOutlet weak var pushNotificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        hyphenateIdLabel.text = EMClient.shared().currentUsername
//        weak var weakSelf = self
//        MBProgressHUD.showAdded(to: view, animated: true)
//        EMClient.shared().getPushNotificationOptionsFromServer { (pushOptions, error) in
//            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
//            if error == nil {
//                if pushOptions?.noDisturbStatus == EMPushNoDisturbStatusClose {
//                    weakSelf?.pushNotificationLabel.text = "Enable"
//                }else {
//                    weakSelf?.pushNotificationLabel.text = "Disable"
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if EMClient.shared().pushOptions?.noDisturbStatus == EMPushNoDisturbStatusClose {
            pushNotificationLabel.text = "Enable"
        }else {
            pushNotificationLabel.text = "Disable"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
