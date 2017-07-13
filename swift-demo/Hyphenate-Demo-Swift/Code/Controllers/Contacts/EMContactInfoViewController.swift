//
//  EMContactInfoViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/29.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import MBProgressHUD

class EMContactInfoViewController: UITableViewController {
 
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    var model: EMUserModel?
    
    init(_ userModel: EMUserModel) {
        super.init(nibName: "EMContactInfoViewController", bundle: nil)
        model = userModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        nicknameLabel.text = model?.nickname
        avatarImage.image = model?.defaultAvatarImage
        if model?.avatarURLPath != nil {
            avatarImage.sd_setImage(with: URL(string: (model?.avatarURLPath)!), placeholderImage: model?.defaultAvatarImage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chatAction(_ sender: UIButton) {
        let chatVC = EMChatViewController((model?.hyphenateID)! , EMConversationTypeChat)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func callVoiceAction(_ sender: UIButton) {
        show("unsupport")
    }
    
    @IBAction func callVideoAction(_ sender: UIButton) {
        show("unsupport")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactInfoCell")
            if tableViewCell == nil {
                tableViewCell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            }
            if indexPath.row == 0 {
                tableViewCell?.textLabel?.text = "Name"
                tableViewCell?.detailTextLabel?.text = model?.nickname
            }else if indexPath.row == 1 {
                tableViewCell?.textLabel?.text = "Hyphenate id"
                tableViewCell?.detailTextLabel?.text = model?.hyphenateID
            }
             return tableViewCell!
        } else {
            var tableViewCell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell")
            if tableViewCell == nil {
                tableViewCell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "DeleteCell")
            }
            tableViewCell?.textLabel?.text = "Delete Contact"
            tableViewCell?.textLabel?.textColor = UIColor.red
            return tableViewCell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            weak var weakSelf = self
           let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cancel = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let delete = UIAlertAction.init(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                MBProgressHUD.showAdded(to: weakSelf?.view, animated: true)
                EMClient.shared().contactManager.deleteContact(weakSelf?.model?.hyphenateID, isDeleteConversation: true, completion: { (username, error) in
                    MBProgressHUD.hide(for: weakSelf?.view, animated: true)
                    weakSelf?.navigationController?.popToRootViewController(animated: true)
                })
            })
            alertController.addAction(cancel)
            alertController.addAction(delete)
            present(alertController, animated: true, completion: nil)
        }
    }
}
