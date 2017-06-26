//
//  ContactsTableViewController.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/27/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import Hyphenate

class ContactsTableViewController:UITableViewController,EMGroupManagerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var dataSource = [AnyObject]()
    var filteredDataSource = [AnyObject]()
    var requestSource = [RequestEntity]()
    var searchController : UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier())
        tableView.register(UINib(nibName: "FriendRequestTableViewCell", bundle: nil), forCellReuseIdentifier: FriendRequestTableViewCell.reuseIdentifier())
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        searchController = UISearchController(searchResultsController:  nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        tableView.tableFooterView = UIView()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
        let image = UIImage(named: "iconAdd")
        let rightButtonItem:UIBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ContactsTableViewController.addContactAction))
        navigationItem.rightBarButtonItem = rightButtonItem
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTableViewController.reloadDataSource), name: NSNotification.Name(rawValue: "kNotification_requestUpdated"), object: nil)

        self.reloadDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addContactAction() {
        let requestController = UIStoryboard(name: "FriendRequest", bundle: nil).instantiateInitialViewController() as! FriendRequestViewController
        self.navigationController!.pushViewController(requestController, animated: true)
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
        self.requestSource.removeAll()
        if let requestArray =  InvitationManager.sharedInstance.getSavedFriendRequests(EMClient.shared().currentUsername) {
            requestSource = requestArray
            if requestArray.count > 0 {
                DispatchQueue.main.async(execute: {
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.mainViewController?.tabBar.items?[1].badgeValue = "\(requestArray.count)"
                })
            } else {
                DispatchQueue.main.async(execute: {
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.mainViewController?.tabBar.items?[1].badgeValue = nil
                })
            }
        }
        
        EMClient.shared().contactManager.getContactsFromServer(completion: { (array, error) in
            if let array = array {
                self.dataSource = array as [AnyObject]
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            } else if let array = EMClient.shared().contactManager.getContacts() {
                self.dataSource = array as [AnyObject]
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if requestSource.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if requestSource.count > 0 {
            switch section {
            case 0:
                return 40
            case 1:
                return 20
            default:
                break
            }
        } else {
            return 0
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if requestSource.count > 0 && section == 0 {
            return "Requests"
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if requestSource.count > 0 {
            switch section {
            case 0:
                let viewName = "requestHeaderView"
                let view: UIView = Bundle.main.loadNibNamed(viewName,
                                                                      owner: self, options: nil)![0] as! UIView
                let headerView: requestHeaderView = view as! requestHeaderView
                headerView.requestCount.text = "(\(requestSource.count))"
                return headerView
                
            case 1:
                let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20)
                let headerView:UIView = UIView(frame: frame)
                headerView.backgroundColor = UIColor(red: 228.0/255, green: 233.0/255, blue: 236.0/255, alpha: 1.0)
                return headerView
            default:
                break
            }
        }
        
        return UIView()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if requestSource.count > 0 {
            switch section {
            case 0:
                return requestSource.count
            case 1:
                return searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource.count : dataSource.count
            default:
                break
            }
        } else {
            return searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource.count : dataSource.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if requestSource.count > 0 {
            
            switch (indexPath as NSIndexPath).section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestTableViewCell
                cell.usernameLabel.text = requestSource[(indexPath as NSIndexPath).row].applicantUsername
                cell.request = requestSource[(indexPath as NSIndexPath).row]
                return cell
                
            case 1:
                if dataSource.count > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier()) as! ContactTableViewCell
                    let text = searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource[indexPath.row] : dataSource[indexPath.row]
                    cell.displayNameLabel.text = text as? String
                    return cell
                }
                
            default:
                break
            }
        } else if dataSource.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier()) as! ContactTableViewCell
            let text = searchController.isActive && searchController.searchBar.text != "" ? filteredDataSource[indexPath.row] : dataSource[indexPath.row]
            cell.displayNameLabel.text = text as? String
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
        
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if requestSource.count > 0 {
            switch (indexPath as NSIndexPath).section {
            case 0:
                return 60
            case 1:
                return 50
            default:
                break
            }
        } else {
            return 50
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if requestSource.count == 0 || (indexPath as NSIndexPath).section == 1 {
            let row = filteredDataSource.count>0 ? filteredDataSource[indexPath.row] : dataSource[indexPath.row]
            if let contact = row as? String {
                let profileController = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileViewController
                profileController.username = contact
                self.navigationController!.pushViewController(profileController, animated: true)
            }
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
