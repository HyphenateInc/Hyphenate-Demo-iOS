//
//  ChatTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/28/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import Hyphenate

class ChatTableViewController: EaseMessageViewController,EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource,EMClientDelegate {
    
    var dismissable = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showRefreshHeader = true
        self.delegate = self
        self.dataSource = self
        navigationController?.view.backgroundColor = UIColor.white
        if dismissable == true {
            let rightButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ChatTableViewController.cancelAction))
            navigationItem.leftBarButtonItem = rightButtonItem
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_unreadMessageCountUpdated"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        HyphenateMessengerHelper.sharedInstance.chatVC = nil
    }
    
    func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Mark: EaseMessageViewControllerDelegate
    
    func messageViewController(_ viewController: EaseMessageViewController!, canLongPressRowAt indexPath: IndexPath!) -> Bool {
        return false
    }
    
    func messageViewController(_ viewController: EaseMessageViewController!, didSelectAvatarMessageModel messageModel: IMessageModel!) {
        
        let profileController = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController
        profileController.username = messageModel.message.from
        self.navigationController!.pushViewController(profileController, animated: true)
    }
    
    // Mark: EaseMessageViewControllerDataSource

    func messageViewController(_ viewController: EaseMessageViewController!, modelFor message: EMMessage!) -> IMessageModel! {
       
        let model = EaseMessageModel(message: message)
        model?.avatarImage = UIImage(named: "placeholder")
        model?.failImageName = "imageDownloadFail";
        
        return model;
    }
}
