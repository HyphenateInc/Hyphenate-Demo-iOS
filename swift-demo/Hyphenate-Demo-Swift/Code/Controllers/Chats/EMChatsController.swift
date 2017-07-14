//
//  EMChatsController.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/13.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

class EMChatsController: EMBaseRefreshTableViewController, EMChatManagerDelegate, EMGroupManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate{
    
    private var _isSearchState: Bool = false;
    
    lazy var dataSource: Array<EMConversationModel> = {()-> Array<EMConversationModel> in
        let _dataSource = Array<EMConversationModel>();
        return _dataSource;
    }()
    
    lazy var resultsSource: Array<EMConversationModel> = {()-> Array<EMConversationModel> in
        let _resultsSource = Array<EMConversationModel>();
        return _resultsSource;
    }()
    
    lazy var searchBar: UISearchBar = {()-> UISearchBar in
        let _searchBar = UISearchBar.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 30));
        _searchBar.placeholder = "Search";
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = false;
        _searchBar.backgroundImage = UIImage .imageWithColor(color: UIColor.white, size: _searchBar.bounds.size);
        _searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(0, 0);
        _searchBar.setSearchFieldBackgroundImage(UIImage.imageWithColor(color: PaleGrayColor, size: _searchBar.bounds.size), for: UIControlState.normal);
        _searchBar.tintColor = AlmostBlackColor;
        return _searchBar;
    }()
    
    lazy var networkStateView: UIView = {()-> UIView in
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.width(), height: 44))
        view.backgroundColor = KermitGreenTwoColor;
        let imgView = UIImageView.init(frame: CGRect.init(x: 10, y: (view.height() - 20) / 2, width: 20, height: 20));
        imgView.image = UIImage(named: "Icon_error_white");
        view.addSubview(imgView);
        let label = UILabel.init(frame: CGRect(x: imgView.width() + imgView.frame.origin.x + 5, y: 0, width: view.width() - imgView.bounds.size.width + 15, height: view.height()))
        label.font = UIFont.systemFont(ofSize: 15.0);
        label.textColor = UIColor.gray;
        label.backgroundColor = UIColor.clear;
        label.text = "Internet disconnected";
        view.addSubview(label);
        return view;
    }();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView();
        edgesForExtendedLayout = UIRectEdge(rawValue: 0);
        tableView.autoresizingMask =  [.flexibleTopMargin,.flexibleHeight];
        
        NotificationCenter.default.addObserver(self, selector: #selector(tableView.reloadData), name: NSNotification.Name(rawValue:KEM_UPDATE_CONVERSATIONS), object: nil)
        
        tableViewDidTriggerHeaderRefresh();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        registerNotifications();
        tableViewDidTriggerHeaderRefresh();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        unregisterNotifications();
    }
    
    func registerNotifications() {
        unregisterNotifications();
        EMClient.shared().chatManager.add(self, delegateQueue: nil);
        EMClient.shared().groupManager.add(self, delegateQueue: nil);
    }
    
    func unregisterNotifications() {
        EMClient.shared().chatManager.remove(self);
        EMClient.shared().groupManager.removeDelegate(self);
    }
    
    // MAKR: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if _isSearchState {
            return resultsSource.count;
        }
        
        return dataSource.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if _isSearchState {
            let cellId = "EMChatsSearchCell";
            var cell = tableView.dequeueReusableCell(withIdentifier: cellId) ;
            if cell == nil {
                cell = Bundle.main.loadNibNamed("EMChatsCell", owner: nil, options: nil)?.first as!  EMChatsCell;
            }
            
            (cell as! EMChatsCell).setConversationModel(model: resultsSource[indexPath.row])
            
            return cell!;
        }
        
        let cellId = "EMChatsCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId);
        if cell == nil {
            cell = Bundle.main.loadNibNamed("EMChatsCell", owner: nil, options: nil)?.first as! EMChatsCell;
        }
        
        (cell as! EMChatsCell).setConversationModel(model: dataSource[indexPath.row])
        
        return cell!;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if _isSearchState {
            return false;
        }
        
        return true;
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let model = dataSource[indexPath.row]
        weak var weakSelf = self
        let deleteAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Delete") { (action, index) in
            model.removeComplation {
                weakSelf?.tableViewDidTriggerHeaderRefresh()
            }
        };
        deleteAction.backgroundColor = UIColor.red
        
        let topAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: model.isTop() ? "Cancel pin to the top" : "Pin to the top") { (action, index) in
            model.setIsTop(isTop: !model.isTop())
            weakSelf?.tableViewDidTriggerHeaderRefresh()
        };
        
        topAction.backgroundColor = UIColor.blue;
        
        return [deleteAction, topAction];
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var model: EMConversationModel?
        if _isSearchState {
            model = resultsSource[indexPath.row]
        } else {
            model = dataSource[indexPath.row]
        }
        
        let chatVC = EMChatViewController(model!.conversation!.conversationId, (model?.conversation?.type)!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_UPDATEUNREADCOUNT), object: nil)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0;
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true);
        _isSearchState = true;
        tableView.isUserInteractionEnabled = false;
        
        return true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isUserInteractionEnabled = true
        if searchBar.text?.characters.count  == 0 {
            resultsSource.removeAll()
            tableView.reloadData()
            return
        }
        
        weak var weakSelf = self
        EMRealtimeSearchUtil.currentUtil().realtimeSearch(withSource: dataSource, searchText: searchText) { (results) in
            if results != nil {
                DispatchQueue.main.async {
                    weakSelf?.resultsSource.removeAll()
                    weakSelf?.resultsSource = results as! Array<EMConversationModel>
                    weakSelf?.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        tableView.isUserInteractionEnabled = true;
        
        return true;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        // TODO clear search Tool
        searchBar.resignFirstResponder();
        searchBar.setShowsCancelButton(false, animated: true)
        _isSearchState = false;
        tableView.reloadData();
    }
    
    // MARK: - action
    
    override func tableViewDidTriggerHeaderRefresh() {
        weak var weakSelf = self
        DispatchQueue.global().async {
            let sortCons = weakSelf?._sortConversationList(aConversationList: EMClient.shared().chatManager.getAllConversations() as! Array<EMConversation>)
            
            var tmpAry = Array<EMConversationModel>()
            var topAry = Array<EMConversationModel>()
            var ret = Array<EMConversationModel>()
            
            for conversation in sortCons! {
                let conversationModel = EMConversationModel(conversation: conversation)
                if conversationModel.isTop() {
                    topAry.append(conversationModel)
                }else {
                    tmpAry.append(conversationModel)
                }
            }
            
            ret += topAry
            ret += tmpAry
            DispatchQueue.main.async {
                weakSelf?.dataSource = ret
                weakSelf?.tableViewDidFinishTriggerHeader(isHeader: true)
                weakSelf?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - EMGroupManagerDelegate
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        tableViewDidTriggerHeaderRefresh();
    }
    
    func conversationListDidUpdate(_ aConversationList: [Any]!) {
        weak var weakSelf = self
        DispatchQueue.global().async {
            let sorted = weakSelf?._sortConversationList(aConversationList: aConversationList as! Array<EMConversation>);
            DispatchQueue.main.async {
                weakSelf?.dataSource.removeAll();
                for conversation in sorted! {
                    self.dataSource.append(EMConversationModel(conversation: conversation));
                }
                weakSelf?.tableViewDidFinishTriggerHeader(isHeader: true);
                weakSelf?.tableView.reloadData();
            }
        }
    }
    
    func groupListDidUpdate(_ aGroupList: [Any]!) {
        tableViewDidTriggerHeaderRefresh();
    }
    
    // MARK: - public
    
    public func setupNavigationItem(navigationItem: UINavigationItem) {
        navigationItem.titleView = searchBar;
        navigationItem.rightBarButtonItem = nil
    }
    
    public func networkChanged(connectionState: EMConnectionState) {
        if connectionState == EMConnectionDisconnected {
            tableView.tableHeaderView = networkStateView;
        } else {
            tableView.tableHeaderView = nil;
        }
    }
    
    // MARK: - private
    
    private func _sortConversationList(aConversationList: Array <EMConversation> ) -> Array <EMConversation> {
        if aConversationList.count == 1 {
            return aConversationList
        }
        let ary = aConversationList.sorted { (conversation1, conversation2) -> Bool in
            if conversation1.latestMessage != nil && conversation2.latestMessage != nil {
                return conversation1.latestMessage.timestamp > conversation2.latestMessage.timestamp;
            }else {
                return true
            }
        };
        
        return ary;
    }
    
}
