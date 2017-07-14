//
//  EMBaseSettingController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/27.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit

class EMBaseSettingController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.backgroundColor = PaleGrayColor
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.separatorColor = CoolGrayColor50
        tableView.isScrollEnabled = false
    }

    func configBackButton() {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(UIImage(named:"Icon_Back"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = AlmostBlackColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = SteelGreyColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
