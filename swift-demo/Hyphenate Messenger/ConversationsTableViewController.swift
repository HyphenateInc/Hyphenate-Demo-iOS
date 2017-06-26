//
//  ConversationsTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/27/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import Hyphenate

public enum DeleteConvesationType: Int {
    case deleteConvesationOnly
    case deleteConvesationWithMessages
}

public protocol ConversationListViewControllerDelegate: class {
    
    func conversationListViewController(_ conversationListViewController:ConversationsTableViewController, didSelectConversationModel conversationModel: AnyObject)
}

@objc public protocol ConversationListViewControllerDataSource: class {
    
    func conversationListViewController(_ conversationListViewController: ConversationsTableViewController, modelForConversation conversation: EMConversation) -> AnyObject
    
    @objc optional func conversationListViewController(_ conversationListViewController:ConversationsTableViewController, latestMessageTitleForConversationModel conversationModel: AnyObject) -> String
    
    @objc optional func conversationListViewController(_ conversationListViewController: ConversationsTableViewController, latestMessageTimeForConversationModel conversationModel: AnyObject) -> String
}

open class ConversationsTableViewController: UITableViewController, EMChatManagerDelegate,ConversationListViewControllerDelegate, ConversationListViewControllerDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var dataSource = [AnyObject]()
    var filteredDataSource = [AnyObject]()
    var searchController : UISearchController!

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController:  nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        tableView.tableFooterView = UIView()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
        let image = UIImage(named: "iconNewConversation")
        let imageFrame = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
        let newConversationButton = UIButton(frame: imageFrame)
        newConversationButton.setBackgroundImage(image, for: UIControlState())
        newConversationButton.addTarget(self, action: #selector(ConversationsTableViewController.composeConversationAction), for: .touchUpInside)
        newConversationButton.showsTouchWhenHighlighted = true
        let rightButtonItem = UIBarButtonItem(customView: newConversationButton)
        navigationItem.rightBarButtonItem = rightButtonItem

        self.tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
  
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataSource), name: NSNotification.Name(rawValue: kNotification_conversationUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataSource), name: NSNotification.Name(rawValue: kNotification_didReceiveMessages), object: nil)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        reloadDataSource()
    }
    
    func reloadDataSource(){
        self.dataSource.removeAll()
        
        var needRemoveConversations = [EMConversation]()
        if let conversations = EMClient.shared().chatManager.getAllConversations() as? [EMConversation]{
            for conversation: EMConversation in conversations {
                if conversation.latestMessage == nil {
                    needRemoveConversations.append(conversation)
                }
            }
        }
        if needRemoveConversations.count > 0 {
            EMClient.shared().chatManager.deleteConversations(needRemoveConversations, isDeleteMessages: true, completion: nil)
        }
        dataSource =  EMClient.shared().chatManager.getAllConversations() as [AnyObject]
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    func composeConversationAction() {
        let contactViewController = ComposeMessageTableViewController()
        let navigationController = UINavigationController(rootViewController: contactViewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        
    }

    // MARK: - Table view data source

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource.count : dataSource.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ConversationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConversationTableViewCell
        
        let conversation = (searchController.isActive && searchController.searchBar.text != "" ?filteredDataSource[indexPath.row] : dataSource[indexPath.row]) as! EMConversation
        
        if let sender = conversation.latestMessage?.from, let recepient = conversation.latestMessage?.to {
            cell.senderLabel.text = sender != EMClient.shared().currentUsername ? sender : recepient
        }
        
        if let latestMessage: EMMessage = conversation.latestMessage {
            let timeInterval: Double = Double(latestMessage.timestamp)
            let date = Date(timeIntervalSince1970:timeInterval)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let dateString = formatter.string(from: date)
            cell.timeLabel.text = dateString
            
            let textMessageBody: EMTextMessageBody = latestMessage.body as! EMTextMessageBody
            cell.lastMessageLabel.text = textMessageBody.text
            
            if conversation.unreadMessagesCount > 0 && conversation.unreadMessagesCount < 100 {
                cell.badgeView.text = "\(conversation.unreadMessagesCount)"
            } else if conversation.unreadMessagesCount > 0 {
                cell.badgeView.text = ".."
            } else {
                cell.badgeView.isHidden = true
            }
        }
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let conversation:EMConversation = dataSource[(indexPath as NSIndexPath).row] as? EMConversation {
            let chatController = ChatTableViewController(conversationID: conversation.conversationId, conversationType: conversation.type)
            chatController?.title = conversation.latestMessage.from
            chatController?.hidesBottomBarWhenPushed = true
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationController!.pushViewController(chatController!, animated: true)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupUnreadMessageCount"), object: nil)
        self.tableView.reloadData()
    }
    
    
    //     MARK: - UISearchBarDelegate
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDataSource = dataSource.filter { (conversation) -> Bool in
            if let conversation = conversation as? EMConversation{
                if let sender = conversation.latestMessage.from{
                    return sender.lowercased().contains(searchText.lowercased())
                }
            }
            return false
        }
        self.tableView.reloadData()
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    open func conversationListViewController(_ conversationListViewController:ConversationsTableViewController, didSelectConversationModel conversationModel: AnyObject){
        
        
    }
    
    open func conversationListViewController(_ conversationListViewController: ConversationsTableViewController, modelForConversation conversation: EMConversation) -> AnyObject
    {
        return String() as AnyObject
    }
    
    open func conversationListViewController(_ conversationListViewController:ConversationsTableViewController, latestMessageTitleForConversationModel conversationModel: AnyObject) -> String
    {
        return String()
    }
    
    open func conversationListViewController(_ conversationListViewController: ConversationsTableViewController, latestMessageTimeForConversationModel conversationModel: AnyObject) -> String
    {
        return String()
    }
 
    @nonobjc open func messagesDidReceive(_ aMessages: [AnyObject]!) {
        HyphenateMessengerHelper.sharedInstance.messagesDidReceive(aMessages)
    }
    
    @nonobjc open func didReceiveMessages(_ aMessages: [AnyObject]!) {
        HyphenateMessengerHelper.sharedInstance.messagesDidReceive(aMessages)
    }
    
}
