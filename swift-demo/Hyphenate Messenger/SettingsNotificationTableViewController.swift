//
//  SettingsNotificationTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/18/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class SettingsNotificationTableViewController: UITableViewController {

    var displayName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "switchCell")
        self.tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "labelCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        title = "Push Notifications"
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsNotificationTableViewController.reloadData), name: NSNotification.Name(rawValue: "kNotification_displayNameUpdated"), object: nil)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell: SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
            cell.title.text = "Enable Push notifications"
            cell.uiswitch.setOn(true, animated: true)
            cell.selectionStyle = .none
            return cell
            
        case 1:
            let cell: SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
            cell.title.text = "Show Message Details on Lock Screen"
            cell.uiswitch.setOn(true, animated: true)
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell: LabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
            cell.titleLabel.text = "Notification display name"
            
            let options = EMClient.shared().pushOptions
            if let displayName = options?.displayName {
                cell.detailLabel.text = "\(displayName)"
            }
            
            displayName = cell.detailLabel.text!
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
            
        default: break
            
        }
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            let settingsDisplayNameVC = DisplayNameTableViewController()
            settingsDisplayNameVC.displayName = displayName
            navigationController?.pushViewController(settingsDisplayNameVC, animated: true)

        default:
            break
        }
    }
}
