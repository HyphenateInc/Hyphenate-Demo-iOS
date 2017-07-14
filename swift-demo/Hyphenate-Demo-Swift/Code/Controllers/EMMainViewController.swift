//
//  EMMainViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/13.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate
import UserNotifications
import SDWebImage

let kDefaultPlaySoundInterval = 3.0   
let kMessageType = "MessageType"   
let kConversationChatter = "ConversationChatter"   
let kGroupName = "GroupName"   

class EMMainViewController: UITabBarController, EMChatManagerDelegate, EMGroupManagerDelegate, EMClientDelegate {
    
    private var _contactsVC : EMContactsViewController?
    private var _chatsVC: EMChatsController?
    private var _settingsVC: EMSettingsViewController?
    
    private var lastPlaySoundDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewControllers()   
        NotificationCenter.default.addObserver(self, selector: #selector(setupUnreadMessageCount), name: NSNotification.Name(rawValue:KNOTIFICATION_UPDATEUNREADCOUNT), object: nil)   
        
        setupUnreadMessageCount()
        registerNotifications()
        EMClient.shared().getPushNotificationOptionsFromServer { (pushOptions, error) in  }
        
//        SDImageCache.shared().shouldDecompressImages = false
//        SDWebImageDownloader.shared().shouldDecompressImages = false
        SDImageCache.shared().maxMemoryCost = 3000 * 3000
    }
    
    // MARK: - Notification Registration
    func registerNotifications() {
        unregisterNotifications()   
        EMClient.shared().add(self, delegateQueue: nil)   
        EMClient.shared().chatManager.add(self, delegateQueue: nil)   
        EMClient.shared().groupManager.add(self, delegateQueue: nil)   
    }
    
    func unregisterNotifications() {
        EMClient.shared().removeDelegate(self)   
        EMClient.shared().chatManager.remove(self)   
        EMClient.shared().groupManager.removeDelegate(self)   
    }
    
    // MARK: - viewControlle
    func loadViewControllers() {
        
        _contactsVC = EMContactsViewController()   
        _contactsVC?.tabBarItem = UITabBarItem.init(title: "Contacts", image: UIImage(named: "Contacts"), tag: 0)
        _contactsVC?.tabBarItem.selectedImage = UIImage(named:"Contacts_active")
        unSelectedTapTabBarItems(item: _contactsVC?.tabBarItem)   
        selectedTapTabBarItems(item: _contactsVC?.tabBarItem)   
        
        _chatsVC = EMChatsController()   
        _chatsVC?.tabBarItem = UITabBarItem.init(title: "Chats", image: UIImage(named: "Chats"), tag: 1)
        _chatsVC?.tabBarItem.selectedImage = UIImage(named:"Chats_active")
        unSelectedTapTabBarItems(item: _chatsVC?.tabBarItem)   
        selectedTapTabBarItems(item: _chatsVC?.tabBarItem)   
        
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        _settingsVC  = storyboard.instantiateViewController(withIdentifier: "EMSettingsViewController") as? EMSettingsViewController
        _settingsVC?.tabBarItem = UITabBarItem.init(title: "Settings", image: UIImage(named:"Settings"), tag: 2)
        _settingsVC?.tabBarItem.selectedImage = UIImage(named:"Settings_active")
        unSelectedTapTabBarItems(item: _settingsVC?.tabBarItem)
        selectedTapTabBarItems(item: _settingsVC?.tabBarItem)
        
        viewControllers = [_contactsVC!,_chatsVC!,_settingsVC!]
        
        selectedIndex = 0
        _contactsVC?.setupNavigationItem(navigationItem: navigationItem)
        
        EMChatDemoHelper.shareHelper.contactsVC = _contactsVC
        EMChatDemoHelper.shareHelper.chatsVC = _chatsVC
        EMChatDemoHelper.shareHelper.settings = _settingsVC
    }
    
    func unSelectedTapTabBarItems(item: UITabBarItem?) {
        if item != nil {
            item!.setTitleTextAttributes(NSDictionary.init(objects: [UIFont.systemFont(ofSize: 11),BlueyGreyColor], forKeys: [NSFontAttributeName as NSCopying,NSForegroundColorAttributeName as NSCopying]) as? [String : Any], for: UIControlState.normal)
        }
    }
    
    func selectedTapTabBarItems(item: UITabBarItem?) {
        if item != nil {
            item!.setTitleTextAttributes(NSDictionary.init(objects: [UIFont.systemFont(ofSize: 11),KermitGreenTwoColor], forKeys: [NSFontAttributeName as NSCopying,NSForegroundColorAttributeName as NSCopying]) as? [String : Any], for: UIControlState.selected)
        }
    }
    
    public func setupUnreadMessageCount() {
        let conversations = EMClient.shared().chatManager.getAllConversations()   
        var unreadCount = 0   
        for conversation in conversations! {
            unreadCount += (Int)((conversation as! EMConversation).unreadMessagesCount)   
        }
        
        if _chatsVC != nil {
            if unreadCount > 0 {
                _chatsVC?.tabBarItem.badgeValue = "\(unreadCount)"   
            } else {
                _chatsVC?.tabBarItem.badgeValue = nil   
            }
        }
    }
    
    // MARK: - UITabbarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            _contactsVC?.setupNavigationItem(navigationItem: navigationItem)
        }
        
        if item.tag == 1 {
            title = "Chats"   
            _chatsVC?.setupNavigationItem(navigationItem: navigationItem)   
        }
        
        if item.tag == 2 {
            title = "Settings"
            clearNavigationItem()   
        }
    }
    
    // MARK: - EMC hatManagerDelegate
    func messagesDidReceive(_ aMessages: [Any]!) {
        setupUnreadMessageCount()   
        for msg in aMessages {
            let state = UIApplication.shared.applicationState   
            switch state {
            case UIApplicationState.active,UIApplicationState.inactive:
                playSoundAndVibration()   
                break   
            case UIApplicationState.background:
                showNotificationWithMessage(msg: (msg as! EMMessage))   
                break   
            }
        }
    }
    
    func conversationListDidUpdate(_ aConversationList: [Any]!) {
        setupUnreadMessageCount()   
    }
    
    func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        _chatsVC?.networkChanged(connectionState: aConnectionState)
    }
    
    func userAccountDidLoginFromOtherDevice() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: false))   
    }
    
    func userAccountDidRemoveFromServer() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: false))   
    }
    
    func clearNavigationItem() {
        navigationItem.titleView = nil   
        navigationItem.leftBarButtonItem = nil   
        navigationItem.rightBarButtonItem = nil   
    }
    
    // MARK - private
    
    private func conversationTypeFromMessageType(chatType:EMChatType) -> EMConversationType {
        var type = EMConversationTypeChat   
        switch chatType {
        case EMChatTypeChat: type = EMConversationTypeChat   
        break   
        case EMChatTypeGroupChat: type = EMConversationTypeGroupChat   
        break   
        case EMChatTypeChatRoom: type = EMConversationTypeChatRoom   
        break   
        default: type = EMConversationTypeChat   
        break   
        }
        
        return type   
    }
    
    func playSoundAndVibration() {
        let timeInterval = Date().timeIntervalSince(lastPlaySoundDate)
        if timeInterval < 3.0 {
            return
        }
        
        lastPlaySoundDate = Date()
        EMCDDeviceManager.sharedInstance().playNewMessageSound()
        EMCDDeviceManager.sharedInstance().playVibration()
    }
    
    func showNotificationWithMessage(msg: EMMessage) {
        let options = EMClient.shared().pushOptions

        var alertStr = ""
        if options?.displayStyle == EMPushDisplayStyleMessageSummary {
            let msgBody = msg.body   
            var msgStr = ""   
            switch msgBody!.type {
            case EMMessageBodyTypeText:
                msgStr = (msgBody as! EMTextMessageBody).text   
                break   
            case EMMessageBodyTypeImage:
                msgStr = "[Image]"
                break   
            case EMMessageBodyTypeLocation:
                msgStr = "[Location]"
                break   
            case EMMessageBodyTypeVoice:
                msgStr = "[Voice]"
                break   
            case EMMessageBodyTypeVideo:
                msgStr = "[Video]"
                break   
            case EMMessageBodyTypeFile:
                msgStr = "[File]"
                break   
            default:
                msgStr = ""
                break   
            }
            
//            repeat {
//                  alertStr = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: msg.from) + ":" + msgStr
//            } while false
            
            alertStr = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: msg.from) + ":" + msgStr
            
        } else {
            alertStr = "You have a new message"
        }
        
        let timeInterval = Date().timeIntervalSince(lastPlaySoundDate)
        var playSound = false
        if timeInterval > 3.0 {
            lastPlaySoundDate = Date()
            playSound = true
        }
        if #available(iOS 10.0, *) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
            let content = UNMutableNotificationContent()
            content.body = alertStr
            if playSound {
                content.sound = UNNotificationSound.default()
            }
            let request = UNNotificationRequest(identifier: msg.messageId, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }else if #available(iOS 8.0, *){
            let notification = UILocalNotification()
            notification.fireDate = Date()
            notification.alertBody = alertStr
            notification.alertAction = "Open"
            notification.timeZone = NSTimeZone.default
            if playSound {
                notification.soundName = UILocalNotificationDefaultSoundName
            }
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}
