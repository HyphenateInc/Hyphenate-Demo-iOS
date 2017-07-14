//
//  EMAboutViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/7/7.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate

class EMAboutViewController: UITableViewController {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        appVersionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        sdkVersionLabel.text = EMClient.shared().version
    }
}
