//
//  GroupListViewController.swift
//  Hyphenate Messenger
//
//  Created by Peng Wan on 9/29/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import Foundation
import Hyphenate
import SlimeRefresh

class GroupListViewController:UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate, EMGroupManagerDelegate, SRRefreshDelegate{
 
    var dataSource:[AnyObject]!
    var slimeView:SRRefreshView!
    var searchBar:EMSearchBar!
    var searchController:EMSearchDisplayController!
    
}
