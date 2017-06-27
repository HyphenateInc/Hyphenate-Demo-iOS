//
//  HyphenateMessengerHelper.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/28/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import Hyphenate

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public enum HIRequestType: Int {
    case hiRequestTypeFriend
    case hiRequestTypeReceivedGroupInvitation
    case hiRequestTypeJoinGroup
}

@objc
class HyphenateMessengerHelper: NSObject, EMClientDelegate, EMChatManagerDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatroomManagerDelegate, EMCallManagerDelegate {

    static let sharedInstance = HyphenateMessengerHelper()
    
    var callTimer : Timer?
    var mainVC : MainViewController?
    var conversationVC : ConversationsTableViewController?
    var contactVC : ContactsTableViewController?
    var chatVC : ChatTableViewController?
    var callVC: CallViewController?
    var callSession: EMCallSession?
    
    deinit {
        EMClient.shared().removeDelegate(self)
        EMClient.shared().groupManager.removeDelegate(self)
        EMClient.shared().contactManager.removeDelegate(self)
        EMClient.shared().roomManager.remove(self)
        EMClient.shared().chatManager.remove(self)
        EMClient.shared().callManager.remove!(self)
    }
    
    override init() {
        super.init()
        initHelper()
    }
    
    func initHelper() {
        EMClient.shared().add(self)
        EMClient.shared().groupManager.add(self)
        EMClient.shared().chatManager.add(self)
        EMClient.shared().contactManager.add(self)
        EMClient.shared().roomManager.add(self)
        EMClient.shared().callManager.add!(self, delegateQueue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HyphenateMessengerHelper.makeCall(notification:)), name: NSNotification.Name(rawValue: "callOutWithChatter"), object: nil)
    }
 
    // MARK: Syncing data
    
    func loadConversationFromDB() {
        
            DispatchQueue.global().async {
                var conversations = [EMConversation]()
                
                // TODO: 
//                for (_, value) in EMClient.shared().chatManager.getAllConversations().enumerated() {
//                    let conversation : EMConversation = value as! EMConversation
//                    if (conversation.latestMessage == nil) {
//                        EMClient.shared().chatManager.deleteConversation(conversation.conversationId, isDeleteMessages: false, completion: nil)
//                    } else {
//                        conversations.append(conversation)
//                    }
//                }
                
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_conversationUpdated"), object: conversations)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_unreadMessageCountUpdated"), object: conversations)
                })
            }
    }
    
    func loadGroupFromServer() {
        EMClient.shared().groupManager.getJoinedGroups();
        EMClient.shared().groupManager.getJoinedGroupsFromServer { (groupList, error) in
            if (error==nil) {
                //reload group from contactVC
            }
        }
    }
    
    func loadPushOptions() {
        EMClient.shared().getPushNotificationOptionsFromServer(completion: nil)
    }
    
   // MARK: EMClientDelegate
    
    func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        
    }
    
    func autoLoginDidCompleteWithError(_ aError: EMError!) {
        if aError != nil {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("login.errorAutoLogin", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else if (EMClient.shared().isConnected) {
            
            DispatchQueue.global().async {
                let flag: Bool = EMClient.shared().migrateDatabaseToLatestSDK()
                if (flag==true) {
                    self.loadGroupFromServer()
                    self.loadConversationFromDB()
                }
            }
        }
    }
    
    func userAccountDidLoginFromOtherDevice() {
        logout()
        let alert = UIAlertController(title: NSLocalizedString("prompt", comment: "Prompt"), message: NSLocalizedString("loggedIntoAnotherDevice", comment: "your login account has been in other places"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func userAccountDidRemoveFromServer() {
        logout()
        let alert = UIAlertController(title: NSLocalizedString("prompt", comment: "Prompt"), message: NSLocalizedString("loginUserRemoveFromServer", comment: "your account has been removed from the server side"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func hangupCallWithReason(areason: EMCallEndReason) {
        stopCallTimer()
        
        if (callSession != nil) {
            let _ = EMClient.shared().callManager.endCall!(callSession?.sessionId, reason:areason)
        }
        
        callSession = nil
        callVC?.close()
        callVC = nil
    }
    
    // EMChatManagerDelegate

    func conversationListDidUpdate(_ aConversationList: [Any]!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_unreadMessageCountUpdated"), object: aConversationList)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_conversationUpdated"), object: aConversationList)
    }
    
    func cmdMessagesDidReceive(_ aCmdMessages: [Any]!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_didReceiveCmdMessages"), object: aCmdMessages)
    }
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        var isRefreshCons = true
        
        for(_, value) in aMessages.enumerated() {
            let message : EMMessage = value as! EMMessage
            let needShowNotif = (message.chatType != EMChatTypeChat) ? needShowNotification(message.conversationId) : true
            if (needShowNotif) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveMessages"), object: message)
            }
            
            if (chatVC == nil) {
                chatVC = getCurrentChatView()
            }
            
            var isSameConversation = false
            if (chatVC != nil) {
                isSameConversation = message.conversationId == chatVC?.conversation.conversationId
            }
            
            if (chatVC==nil || isSameConversation==false) {
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveMessages"), object: message)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_unreadMessageCountUpdated"), object: nil)
                return
            }
            
            if (isSameConversation==true) {
                isRefreshCons = false
            }
        }
        
        if isRefreshCons {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didReceiveMessages"), object: aMessages[0])

            NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_unreadMessageCountUpdated"), object: nil)

        }
    }
        
    // MARK: EMGroupManagerDelegate
    
    func didLeave(_ aGroup: EMGroup!, reason aReason: EMGroupLeaveReason) {
        
        var str : String? = nil
        
        if aReason == EMGroupLeaveReasonBeRemoved {
            str = "You are kicked out from group: \(aGroup.subject) [\(aGroup.groupId)]"
        } else if aReason == EMGroupLeaveReasonDestroyed {
            str = "Group: \(aGroup.subject) [\(aGroup.groupId)] is destroyed"
        }
        
        if (str?.characters.count)! > 0 {
            let alert = UIAlertController(title: nil, message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        var viewControllers = self.mainVC?.navigationController?.viewControllers
        var chatViewController : ChatTableViewController? = nil
        for(_, value) in (viewControllers?.enumerated())! {
            if value is ChatTableViewController {
                let viewController = value as! ChatTableViewController
                if aGroup.groupId == viewController.conversation.conversationId {
                    chatViewController = viewController
                    break
                }
            }
        }
        
        if chatViewController != nil {
            for (index, value) in (viewControllers?.enumerated())! {
                if value == chatViewController {
                    viewControllers?.remove(at: index)
                }
            }
        }
        
        if (viewControllers?.count)! > 0 {
            mainVC?.navigationController?.setViewControllers([(viewControllers?[0])!], animated: true)
        } else {
            mainVC?.navigationController?.setViewControllers(viewControllers!, animated: true)
        }
    }
    
    func joinGroupRequestDidReceive(_ aGroup: EMGroup!, user aUsername: String!, reason aReason: String!) {
        
        if !(aGroup != nil) || !(aUsername != nil) {
            return
        }
        var reasonString = aReason
        
        if !(reasonString != nil) || reasonString?.characters.count == 0 {
            reasonString = NSLocalizedString("group.joinRequest", comment: "\(aUsername) requested to join the group \'\(aGroup.subject)\'")
        } else {
            reasonString = NSLocalizedString("group.joinRequestWithName", comment: "\(aUsername) requested to join the group \'\(aGroup.subject)\': \(aReason)")
        }
        
        let requestDict : [String:AnyObject] = ["title": aGroup.subject as AnyObject, "groupId": aGroup.groupId as AnyObject, "username":aUsername as AnyObject, "groupname":aGroup.subject as AnyObject, "applyMessage":reasonString as AnyObject, "requestType":HIRequestType.hiRequestTypeJoinGroup.rawValue as AnyObject]
        
//        [[FriendRequestViewController shareController] addNewRequest:requestDict];
//        
//        if (self.mainVC) {
//            
//            #if !TARGET_IPHONE_SIMULATOR
//                [self.mainVC playSoundAndVibration];
//            #endif
//        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_didReceiveRequest"), object: requestDict)
    }
    
    func didJoin(_ aGroup: EMGroup!, inviter aInviter: String!, message aMessage: String!) {
        
        let alert = UIAlertController(title:NSLocalizedString("prompt", comment: "prompt"), message: "\(aInviter) invite you to group: \(aGroup.subject) [\(aGroup.groupId)]", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func joinGroupRequestDidDecline(_ aGroupId: String!, reason aReason: String!) {
        
        var reasonString = aReason
        
        if (reasonString != nil || reasonString?.characters.count == 0) {
            reasonString = NSLocalizedString("group.joinRequestDeclined", comment: "be declined to join group \'\(aGroupId)\'")
        }
        
        let alert = UIAlertController(title:NSLocalizedString("prompt", comment: "prompt"), message: reasonString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func joinGroupRequestDidApprove(_ aGroup: EMGroup!) {
        let alert = UIAlertController(title:NSLocalizedString("prompt", comment: "prompt"), message: NSLocalizedString("group.agreedAndJoined", comment: "agreed to join the group of \'\(aGroup.subject)\'"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func groupInvitationDidReceive(_ aGroupId: String!, inviter aInviter: String!, message aMessage: String!) {
        if (aGroupId == nil || aInviter == nil) {
            return;
        }
        
        let requestDict : [String:AnyObject] = ["title": "" as AnyObject, "groupId": aGroupId as AnyObject, "username":aInviter as AnyObject, "groupname":"" as AnyObject, "applyMessage":aMessage as AnyObject, "requestType":HIRequestType.hiRequestTypeReceivedGroupInvitation.rawValue as AnyObject]
        
//        [[FriendRequestViewController shareController] addNewRequest:requestDict];
//        
//        if ((mainVC) != nil) {
//            
//            #if !TARGET_IPHONE_SIMULATOR
//                [self.mainVC playSoundAndVibration];
//            #endif
//        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_didReceiveRequest"), object: requestDict)
    }

    // MARK: EMContactManagerDelegate
    
    func friendRequestDidApprove(byUser aUsername: String!) {
        
        let alert = UIAlertController(title:nil, message: "\(aUsername) accepted friend request", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func friendRequestDidDecline(byUser aUsername: String!) {
        
        let alert = UIAlertController(title:nil, message: "\(aUsername) declined friend request", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func friendshipDidRemove(byUser aUsername: String!) {
        
        var viewControllers = mainVC?.navigationController?.viewControllers
        var chatViewController: ChatTableViewController? = nil
        
        
        for viewController in viewControllers! {
            
            let chatVC = viewController as! ChatTableViewController
            if viewController is ChatTableViewController && aUsername == chatVC.conversation.conversationId {
                chatViewController = chatVC
                break
            }
        }
        
        if chatViewController != nil {
            viewControllers?.remove(at: (viewControllers?.index(of: chatViewController!))!)
            
            if viewControllers?.count > 0 {
                mainVC?.navigationController?.setViewControllers([viewControllers![0]], animated: true)
            } else {
                mainVC?.navigationController?.setViewControllers(viewControllers!, animated: true)
            }
        
        }
        
        let alert = UIAlertController(title:nil, message: "\(NSLocalizedString("delete", comment: "delete")) \(aUsername)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
        contactVC?.reloadDataSource()
    }
    
    func friendshipDidAdd(byUser aUsername: String!) {
        contactVC?.reloadDataSource()
    }
    
    func friendRequestDidReceive(fromUser aUsername: String!, message aMessage: String!) {
        if (aUsername == nil) {
            return;
        }
        
        var message:String? = aMessage
        
        
        if (message == nil) {
            message = "\(NSLocalizedString("friend.somebodyAddWithName", comment: "\(aUsername) added you as a friend"))"
        }
        
        let requestDict: [String : AnyObject] = ["title": aUsername as AnyObject, "username": aUsername as AnyObject, "applyMessage": message! as AnyObject, "requestType":HIRequestType.hiRequestTypeFriend.rawValue as AnyObject]
        
        self.addNewRequest(requestDict)
        
        if (mainVC != nil) {
            
            #if !TARGET_IPHONE_SIMULATOR
//                [self.mainVC playSoundAndVibration];
                
                let isAppActive = UIApplication.shared.applicationState == .active
                
                if (isAppActive == false) {
                    
                    let notification: UILocalNotification = UILocalNotification()
                    notification.fireDate = Date()
                    notification.alertBody = "\(NSLocalizedString("friend.somebodyAddWithName", comment: "\(aUsername) added you as a friend"))"
                    notification.alertAction = "\(NSLocalizedString("open", comment: "Open"))"
                    notification.timeZone = TimeZone.current
                }
            #endif
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_didReceiveRequest"), object: requestDict)
    }
    
    
    func addNewRequest(_ dictionary: [String : AnyObject]) {
        var dataSource = InvitationManager.sharedInstance.getSavedFriendRequests(EMClient.shared().currentUsername)
        if let applyUsername = dictionary["username"] as? String{
            if let style = dictionary["requestType"]  as? Int{
                if dataSource?.count > 0 {
                    var i = dataSource!.count - 1
                    while i >= 0 {
                        let oldEntity = dataSource![i]
                        let oldStyle = oldEntity.style
                        if oldStyle == style && (applyUsername == oldEntity.applicantUsername) {
                            if style != HIRequestType.hiRequestTypeFriend.rawValue {
                                let newGroupid = dictionary["groupname"] as? String
                                if newGroupid != nil{
                                    break
                                }
                                if newGroupid?.characters.count > 0 || (newGroupid == oldEntity.groupId) {
                                    break
                                }
                            }
                            oldEntity.reason = (dictionary["applyMessage"] as! String)
                            
                            if let index = dataSource!.index(where: {$0 == oldEntity}){
                                dataSource!.remove(at: index)
                            }
                            
                            dataSource!.insert(oldEntity, at: 0)
                            return
                        }
                        i -= 1
                    }
                }
                
                //new apply
                let newEntity = RequestEntity()
                newEntity.applicantUsername = (dictionary["username"] as! String)
                newEntity.style = (dictionary["requestType"] as! Int)
                newEntity.reason = (dictionary["applyMessage"] as! String)
                let loginName = EMClient.shared().currentUsername
                newEntity.receiverUsername = loginName!
                let groupId = (dictionary["groupId"] as? String)
                newEntity.groupId = groupId?.characters.count > 0 ? groupId! : ""
                let groupSubject = (dictionary["groupname"] as? String)
                newEntity.groupSubject = groupSubject?.characters.count > 0 ? groupSubject! : ""
                let loginUsername = EMClient.shared().currentUsername
                InvitationManager.sharedInstance.addInvitation(newEntity, loginUser: loginUsername!)
            }
        }
    }
    
    func callNetworkDidChange(_ aSession: EMCallSession!, status aStatus: EMCallNetworkStatus) {
        if aSession.sessionId == self.callSession?.sessionId {
            self.callVC?.setNetwork(aStatus)
        }
    }

    // MARK: EMCallManagerDelegate
    
    func makeCall(notification: Notification) {
        if let dict: [String: AnyObject] = notification.object as? [String : AnyObject] {
            if let chatter = dict["chatter"] as? String{
                if let type = dict["type"]{
                    makeCallWithUserName(userName:chatter, isVideo: type.boolValue)
                }
            }
        }
    }
    
    func callDidReceive(_ aSession: EMCallSession!) {
        if callSession != nil && callSession?.status != EMCallSessionStatusDisconnected {
            EMClient.shared().callManager.endCall!(aSession.sessionId, reason: EMCallEndReasonBusy)
        }
        
        if UIApplication.shared.applicationState != .active {
            EMClient.shared().callManager.endCall!(aSession.sessionId, reason: EMCallEndReasonFailed)
        }
        
        callSession = aSession
        
        if (callSession != nil) {
            startCallTimer()
            
            callVC = CallViewController(session: callSession, isCaller: false, status: NSLocalizedString("call.established", comment: "Call connection established"))
            callVC?.modalPresentationStyle = .overFullScreen
            mainVC?.present(callVC!, animated: false, completion: nil)
        }
    }
    
    func callDidConnect(_ aSession: EMCallSession!) {
        if aSession.sessionId == callSession?.sessionId {
            callVC?.statusLabel.text = NSLocalizedString("call.established", comment: "Establish call")
        }
        
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            let alert = UIAlertController(title:"Audio Error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        do {
            try audioSession.setActive(true)
        } catch {
            let alert = UIAlertController(title:"Audio Error", message:nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func callDidAccept(_ aSession: EMCallSession!) {
        if UIApplication.shared.applicationState != .active {
            EMClient.shared().callManager.endCall!(aSession.sessionId, reason: EMCallEndReasonFailed)
        }
        
        if aSession.sessionId == self.callSession?.sessionId {
            self.stopCallTimer()
            
            let connectStr = aSession.connectType == EMCallConnectTypeRelay ? "Relay connection" : "Direct connection"
            self.callVC?.statusLabel.text = "\(connectStr)"
            self.callVC?.timeLabel.isHidden = false
            self.callVC?.startTimer()
            self.callVC?.showCallInfo()
            self.callVC?.cancelButton.isHidden = false
            self.callVC?.rejectButton.isHidden = true
            self.callVC?.answerButton.isHidden = true
        }
    }

    func callDidEnd(_ aSession: EMCallSession!, reason aReason: EMCallEndReason, error aError: EMError!) {
        if aSession.sessionId == self.callSession?.sessionId {
            self.stopCallTimer()
            self.callSession = nil
            self.callVC?.close()
            self.callVC = nil
            if aReason != EMCallEndReasonHangup {
                var reasonStr = ""
                switch aReason {
                case EMCallEndReasonNoResponse:
                    reasonStr = NSLocalizedString("call.noResponse", comment: "NO response")
                    break
                    
                case EMCallEndReasonDecline:
                    reasonStr = NSLocalizedString("call.rejected", comment: "Reject the call")
                    break
                    
                case EMCallEndReasonBusy:
                    reasonStr = NSLocalizedString("call.inProgress", comment: "In the call...")
                    break

                case EMCallEndReasonFailed:
                    reasonStr = NSLocalizedString("call.connectFailed", comment: "Connect failed")
                    break

                default:
                    break
                }
                
                if (aError != nil) {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: aError.errorDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: nil, message: reasonStr, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func startCallTimer() {
        self.callTimer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(HyphenateMessengerHelper.cancelCall), userInfo: nil, repeats: false)
    }
    
    func stopCallTimer() {
        if (self.callTimer==nil) {
            return
        }
        self.callTimer?.invalidate()
        self.callTimer = nil
    }

    func cancelCall() {
        hangupCallWithReason(areason: EMCallEndReasonNoResponse)
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("call.autoHangup", comment: "No response and Hang up"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func makeCallWithUserName(userName: String, isVideo: Bool) {
        if userName.characters.count == 0 {
            return
        }
        
        let completionBlock = {(session: EMCallSession?, error: EMError?) in
            
            if error == nil && session != nil {
                self.callSession = session
                self.startCallTimer()
                self.callVC = CallViewController(session: self.callSession, isCaller: true, status: NSLocalizedString("call.connecting", comment: "Connecting..."))
                self.mainVC?.present(self.callVC!, animated: false, completion: nil)
            }
        }
        
        if isVideo {
            EMClient.shared().callManager.startVideoCall!(userName, completion: { (session, error) in
                completionBlock(session, error)
            })
        } else {
            EMClient.shared().callManager.startVoiceCall!(userName, completion: { (session, error) in
                completionBlock(session, error)
            })
        }
    }
    
    func logout() {
        
        EMClient.shared().logout(false) { (error) in
            if (error == nil) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "KNotification_logout"), object: nil)
            } else {
                print("Error!!! Failed to logout properly!")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "KNotification_logout"), object: nil)
            }
            let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScene")
            UIApplication.shared.keyWindow?.rootViewController = loginController
        }
    }
    
    func getCurrentChatView() -> ChatTableViewController? {
        
        let viewControllers = mainVC?.viewControllers
        var chatViewController : ChatTableViewController? = nil
        
        for viewcontroller in viewControllers!{
            
            if viewcontroller is UINavigationController {
                
                let navigationController: UINavigationController = viewcontroller as! UINavigationController
                
                for vc in navigationController.viewControllers {
                    if vc is ChatTableViewController {
                        chatViewController = vc as? ChatTableViewController
                        break
                    }
                }
                
            }
            
        }
        return chatViewController
    }
    
    func needShowNotification(_ fromChatter:String) -> Bool {
        var ret = true
        let igGroupIds : Array = EMClient.shared().groupManager.getGroupsWithoutPushNotification(nil)
        
        for (_, value) in igGroupIds.enumerated() {
            let str:String = value as! String
            if str == fromChatter {
                ret = false
                break;
            }
        }
        return ret
    }
}



