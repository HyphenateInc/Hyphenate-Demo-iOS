//
//  SettingsTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/27/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let titleFrame = CGRect(x: 0, y: 0, width: 32, height: 32)
        let title:UILabel = UILabel(frame: titleFrame)
        title.text = "Settings"
        navigationItem.titleView = title
        self.tableView.backgroundColor = UIColor(red: 228.0/255.0, green: 233.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "switchCell")
        self.tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "labelCell")


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let logoutButton = UIButton(type: .custom)
        logoutButton.backgroundColor = UIColor.hiPrimaryRed()
        logoutButton.setTitle("Sign Out", for: .normal)
        logoutButton.addTarget(self, action: #selector(SettingsTableViewController.logoutAction), for: .touchUpInside)
        logoutButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 265, width: UIScreen.main.bounds.size.width, height: 45)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 220, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 220))
            footerView.addSubview(logoutButton)
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UIScreen.main.bounds.size.height - 220
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        switch (indexPath as NSIndexPath).row {
        case 0:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "About"
            cell.accessoryType = .disclosureIndicator
            return cell

        case 1:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Push Notifications"
            cell.accessoryType = .disclosureIndicator
            return cell

        case 2:
            let cell: LabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
            cell.titleLabel.text = "Hyphenate ID"
            cell.selectionStyle = .none
            if let hyphenateID = EMClient.shared().currentUsername {
                cell.detailLabel.text = "\(hyphenateID)"
            }
            return cell

        case 3:
            let switchCell: SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
            switchCell.uiswitch.setOn(true, animated: true)
            switchCell.title.text = "Adaptive Video Bitrate"
            return switchCell

        default: break
            
        }
     return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let settingsAboutVC = SettingsAboutTableViewController()
            navigationController?.pushViewController(settingsAboutVC, animated: true)
            
        case 1:
            let settingsNotificationVC = SettingsNotificationTableViewController()
            navigationController?.pushViewController(settingsNotificationVC, animated: true)
        default:break
            
        }
    }
    
    func logoutAction() {
        EMClient.shared().logout(false) { (error) in
            if let _ = error {
                let alert = UIAlertController(title:"Sign Out error", message: "Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScene")
                UIApplication.shared.keyWindow?.rootViewController = loginController               

            }
        }
    }
}
