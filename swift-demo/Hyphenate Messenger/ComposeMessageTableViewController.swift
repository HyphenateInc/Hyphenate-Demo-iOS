//
//  ComposeMessageTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/10/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class ComposeMessageTableViewController: UITableViewController,EMGroupManagerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var dataSource = [AnyObject]()
    var filteredDataSource = [AnyObject]()
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier())
        
        searchController = UISearchController(searchResultsController:  nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        tableView.tableFooterView = UIView()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
        title = "New Message"

        let rightButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ComposeMessageTableViewController.cancelAction))
        navigationItem.leftBarButtonItem = rightButtonItem
        
        self.reloadDataSource()
    }
    
    func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredDataSource = dataSource.filter { (username) -> Bool in
            return username.lowercased.contains(searchText.lowercased())
        }
        self.tableView.reloadData()
    }
    
    func reloadDataSource(){
        self.dataSource.removeAll()
        
        EMClient.shared().contactManager.getContactsFromServer(completion: { (array, error) in
            if let source = array {
                self.dataSource = source as [AnyObject]
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            } else if let contacts = EMClient.shared().contactManager.getContacts() {
                self.dataSource = contacts as [AnyObject]
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource.count : dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier()) as! ContactTableViewCell
        let text = searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource[indexPath.row] : dataSource[indexPath.row]
        cell.displayNameLabel.text = text as? String
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = filteredDataSource.count>0 ? filteredDataSource[indexPath.row] : dataSource[indexPath.row]
        if let contact = row as? String {
            let chatController = ChatTableViewController(conversationID: contact, conversationType: EMConversationTypeChat)
            chatController?.dismissable = true
            chatController?.title = contact
            chatController?.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(chatController!, animated: true)
        }
    }
    
    
    //     MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDataSource = dataSource.filter { (username) -> Bool in
            return username.lowercased.contains(searchText.lowercased())
        }
        self.tableView.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
}
