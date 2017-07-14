//
//  EMChatsSettingViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/7/7.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate

class EMChatsSettingViewController: EMBaseSettingController {
    
    var autoAcceptInvitation = false
    lazy var autoAcceptSwitch = {()-> UISwitch in
        let switchCotrol = UISwitch()
        switchCotrol.addTarget(self, action: #selector(autoAcceptAction), for: UIControlEvents.valueChanged)
        return switchCotrol
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configBackButton()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AcceptInviteCell")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "AcceptInviteCell")
        }
        
        cell?.textLabel?.text = "Accept group invites automatically"
        autoAcceptSwitch.frame = CGRect.init(x: tableView.width() - 65, y: 8, width: 50, height: 30)
        cell?.contentView.addSubview(autoAcceptSwitch)
        
        return cell!
    }
    
    func loadOptions() {
        let options = EMClient.shared().options
        autoAcceptInvitation = (options?.isAutoAcceptGroupInvitation)!
        autoAcceptSwitch.setOn(autoAcceptInvitation, animated: true)
        tableView.reloadData()
    }
    
    func autoAcceptAction(_ sender: UISwitch) {
        let options = EMClient.shared().options
        options?.isAutoAcceptGroupInvitation = sender.isOn
    }
}
