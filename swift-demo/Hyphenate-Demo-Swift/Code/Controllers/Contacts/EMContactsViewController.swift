//
//  EMContactsViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/13.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate
import MBProgressHUD

let  KEM_CONTACT_BASICSECTION_NUM = 3

class EMContactsViewController: EMBaseRefreshTableViewController, UISearchBarDelegate{
    
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
    
    
    var contacts = Array<Any>()
    var contactRequests = Array<Any>()
    var groupNotifications = Array<Any>()
    
    private var sectionTitles = Array<String>()
    private var searchSource = Array<EMUserModel>()
    private var searchResults = Array<EMUserModel>()
    private var isSearchState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge(rawValue: 0);
        tableView.sectionIndexColor = BrightBlueColor
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.dataSource = self
        setupNavigationItem(navigationItem: navigationItem)
        reloadGroupNotifications()
        reloadContactRequests()
        tableViewDidTriggerHeaderRefresh()
    }
    
    public func setupNavigationItem(navigationItem: UINavigationItem) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn.setImage(UIImage(named:"Icon_Add"), for: UIControlState.normal)
        btn.setImage(UIImage(named:"Icon_Add"), for: UIControlState.highlighted)
        btn.addTarget(self, action: #selector(addContactAction), for: UIControlEvents.touchUpInside)
        let rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.titleView = searchBar
    }
    
    override func tableViewDidTriggerHeaderRefresh() {
        if isSearchState {
            tableViewDidFinishTriggerHeader(isHeader: true)
            return
        }
        
        weak var weakSelf = self
        EMClient.shared().contactManager.getContactsFromServer { (contactsList, error) in
            if error == nil {
                DispatchQueue.global().async {
                    weakSelf?.updateContacts(bubbyList: contactsList)
                    weakSelf?.tableViewDidFinishTriggerHeader(isHeader: true)
                    DispatchQueue.main.async {
                        weakSelf?.tableView.reloadData()
                    }
                }
            }else {
                weakSelf?.tableViewDidFinishTriggerHeader(isHeader: true)
            }
        }
    }
    
    func loadContactFromServer() {
        tableViewDidTriggerHeaderRefresh()
    }
    
    func reloadContacts() {
        let buddyList = EMClient.shared().contactManager.getContacts()
        updateContacts(bubbyList: buddyList)
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.tableView.reloadData()
            weakSelf?.refreshControl?.endRefreshing()
        }
    }
    
    func reloadContactRequests() {
        weak var weakSelf = self
        DispatchQueue.main.async {
            let contactApplys = EMApplyManager.defaultManager.contactApplys()
            weakSelf?.contactRequests = contactApplys!
            weakSelf?.tableView.reloadData()
            EMChatDemoHelper.shareHelper.setupUntreatedApplyCount()
        }
    }
    
    func reloadGroupNotifications() {
        weak var weakSelf = self
        DispatchQueue.main.async {
            let groupApplys = EMApplyManager.defaultManager.groupApplys()
            weakSelf?.contactRequests = groupApplys!
            weakSelf?.tableView.reloadData()
            EMChatDemoHelper.shareHelper.setupUntreatedApplyCount()
        }
    }
    
    func updateContacts(bubbyList: Array<Any>?) {
        let blockList = EMClient.shared().contactManager.getBlackList() as Array
        let contacts = NSMutableArray.init(array: bubbyList!)
        for blockId in blockList {
            contacts.remove(blockId)
        }
        sortContacts(contactList: contacts as! Array<String>)
        weak var weakSelf = self
        EMUserProfileManager.sharedInstance.loadUserProfileInBackgroundWithBuddy(buddyList: contacts as! Array<String>, saveToLocat: true) { (success, error) in
            if success {
                DispatchQueue.global().async {
                    weakSelf?.sortContacts(contactList: contacts as! Array<String>)
                    DispatchQueue.main.async {
                        weakSelf?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func sortContacts(contactList: Array<String>) {
        let collation =  UILocalizedIndexedCollation.current()
        let _sectionTitles = NSMutableArray.init(array: collation.sectionTitles)
        let _contacts = NSMutableArray()
        for _ in 0..<_sectionTitles.count {
            _contacts.add(Array<EMUserModel>())
        }
        
        // TODO
        let ary = contactList.sorted { (contact1, contact2) -> Bool in
            let nickname1 = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: contact1)
            let nickname2 = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: contact2)
            return nickname1 > nickname2
        }
        
        var _searchSource = Array<EMUserModel>()
        for hyphenateId in ary {
            let model = EMUserModel.createWithHyphenateId(hyphenateId: hyphenateId)
            if model != nil{
                let sectionIndex = collation.section(for: model!, collationStringSelector: #selector(getter: EMUserModel.nickname))
                var array = _contacts[sectionIndex] as! Array<EMUserModel>
                array.append(model as! EMUserModel)
                _contacts[sectionIndex] = array
                _searchSource.append(model as! EMUserModel)
            }
        }
        
        var indexSet: NSMutableIndexSet?
        for (idx, obj) in _contacts.enumerated() {
            let _obj = (obj as! Array<Any>)
            if _obj.count == 0 {
                if indexSet == nil {
                    indexSet = NSMutableIndexSet.init()
                }
                indexSet?.add(idx)
            }
        }
        
        if indexSet != nil {
            _contacts.removeObjects(at: indexSet! as IndexSet)
            _sectionTitles.removeObjects(at: indexSet! as IndexSet)
        }
        
        searchSource = _searchSource
        sectionTitles = _sectionTitles as! Array<String>
        contacts = _contacts as! Array<Any>
    }
    
    // MARK: - Action Method
    func addContactAction() {
        let addContactViewController = EMAddContactViewController.init(nibName: "EMAddContactViewController", bundle: nil)
        let nav = UINavigationController.init(rootViewController: addContactViewController)
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchState {
            return 1
        }
        
        return sectionTitles.count + 1
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return  sectionTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchState {
            return searchResults.count
        }
        
        if section == 0 {
            return contactRequests.count
        }
        
        let ary = contacts[section - 1] as! Array<Any>
        return ary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && !isSearchState {
            let model = contactRequests[indexPath.row]
            return fetchApplyRequestCell(withTableView: tableView, model: model as! EMApplyModel)
        }

        var model: EMUserModel?
        if isSearchState {
            model = searchResults[indexPath.row]
        }else {
            model = (contacts[indexPath.section - 1] as! Array)[indexPath.row]
        }
        
        return fetchContactCell(withTableView: tableView, model: model!)
    }
    
    func fetchApplyRequestCell(withTableView: UITableView , model: EMApplyModel) -> UITableViewCell {
        var cell = withTableView.dequeueReusableCell(withIdentifier: "EMApplyRequestCell")
        if cell == nil {
            cell = Bundle.main.loadNibNamed("EMApplyRequestCell", owner: self, options: nil)?.first as! EMApplyRequestCell
        }
        
        weak var weakSelf = self
        (cell as! EMApplyRequestCell).set(model: model)
        (cell as! EMApplyRequestCell).acceptApply = { (acceptModel) -> Void in
            if acceptModel.style == .contact {
                MBProgressHUD.showAdded(to: weakSelf?.view, animated: true)
                EMClient.shared().contactManager.approveFriendRequest(fromUser: acceptModel.applyHyphenateId, completion: { (username, error) in
                    MBProgressHUD.hide(for: weakSelf?.view, animated: true)
                    if error == nil {
                        EMApplyManager.defaultManager.removeApplyRequest(model: acceptModel)
                    } else {
                        weakSelf?.showAlert("Accept failed", error!.errorDescription)
                    }
                    DispatchQueue.main.async {
                        weakSelf?.reloadContactRequests()
                    }
                })
            }
            // TODO: groups
        }
        
        (cell as! EMApplyRequestCell).declineApply = { (declineModel) -> Void in
            if declineModel.style == .contact {
                MBProgressHUD.showAdded(to: weakSelf?.view, animated: true)
                EMClient.shared().contactManager.declineFriendRequest(fromUser: declineModel.applyHyphenateId, completion: { (username, error) in
                    MBProgressHUD.hide(for: weakSelf?.view, animated: true)
                    if error == nil {
                        EMApplyManager.defaultManager.removeApplyRequest(model: declineModel)
                    } else {
                        weakSelf?.showAlert("Decline failed", error!.errorDescription)
                    }
                    DispatchQueue.main.async {
                        weakSelf?.reloadContactRequests()
                    }
                })
            }
            // TODO: groups
        }
        return cell!
    }
    
    func fetchContactCell(withTableView: UITableView, model: EMUserModel) -> UITableViewCell {
        let cellItentify = "EMContactCell"
        var cell = withTableView.dequeueReusableCell(withIdentifier: cellItentify)
        if cell == nil {
            cell = Bundle.main.loadNibNamed("EMContactCell", owner: self, options: nil)?.first as! EMContactCell
        }
        
        (cell as! EMContactCell).set(model: model)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && isSearchState == false {
            return
        }
        var model: EMUserModel?
        if isSearchState {
            model = searchResults[indexPath.row]
        }else {
            model = (contacts[indexPath.section - 1] as! Array)[indexPath.row]
        }
        
        let contactInfo = EMContactInfoViewController.init(model!)
        navigationController?.pushViewController(contactInfo, animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        isSearchState = true
        tableView.isUserInteractionEnabled = false
        
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.isUserInteractionEnabled = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isUserInteractionEnabled = true
        if searchBar.text?.characters.count == 0 {
            searchResults.removeAll()
            tableView.reloadData()
            
            return
        }
        
        weak var weakSelf = self
        EMRealtimeSearchUtil.currentUtil().realtimeSearch(withSource: searchSource as Array<EMRealtimeSearchUtilDelegate>, searchText: searchText) { (results) in
            if results != nil {
                DispatchQueue.main.async {
                    weakSelf?.searchResults = results as! Array<EMUserModel>
                    weakSelf?.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        EMRealtimeSearchUtil.currentUtil().realTimeSearchStop()
        isSearchState = false
        tableView.reloadData()
    }
}
