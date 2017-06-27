//
//  SettingsAboutTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/17/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class SettingsAboutTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "labelCell")
        title = "About"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: LabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell

        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.titleLabel.text = "App Version"
            
            cell.detailLabel.text = "unknown"
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                cell.detailLabel.text = version
            }
            
        case 1:
            cell.titleLabel.text = "SDK Version"
            cell.detailLabel.text = EMClient.shared().version
            
        case 2:
            cell.titleLabel.text = "EaseUI Library Version"
            cell.detailLabel.text = ""
            
        default: break
            
        }
        return cell
    }
}
