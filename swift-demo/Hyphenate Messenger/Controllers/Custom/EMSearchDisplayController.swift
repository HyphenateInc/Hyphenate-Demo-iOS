//
//  EMSearchDisplayController.swift
//  Hyphenate Messenger
//
//  Created by Peng Wan on 9/30/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import Foundation
import UIKit

class EMSearchDisplayController/*:UISearchDisplayController, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate*/{
    /*
    var resultsSource = [AnyObject]()
    var editingStyle:UITableViewCellEditingStyle
    var cellForRowAtIndexPathCompletion: (UITableView, NSIndexPath)->UITableViewCell?
    var canEditRowAtIndexPath = false
    var heightForRowAtIndexPathCompletion: CGFloat = 0.0
    var didSelectRowAtIndexPathCompletion:(UITableView, NSIndexPath)->Void
    var didDeselectRowAtIndexPathCompletion:(UITableView, NSIndexPath)->Void
    var numberOfSectionsInTableViewCompletion:(UITableView)-> Int?
    var numberOfRowsInSectionCompletion:(UITableView, NSInteger)->Int?
    
    override init(searchBar: UISearchBar, contentsController viewController: UIViewController) {
        super.init(searchBar: searchBar, contentsController: viewController)
        
        // Custom initialization
        self.resultsSource = [AnyObject]()
        self.editingStyle = .Delete
        self.searchResultsDataSource! = self
        self.searchResultsDelegate! = self
        self.searchResultsTitle! = NSLocalizedString("searchResults", comment: "The search results")
        
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sectionCount = self.numberOfSectionsInTableViewCompletion(tableView) {
            return sectionCount
        }
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rowCount = self.numberOfRowsInSectionCompletion(tableView,section) {
            return rowCount
        }
        // Return the number of rows in the section.
        return self.resultsSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = self.cellForRowAtIndexPathCompletion(tableView,indexPath) {
            return cell
        }
        else {
            var CellIdentifier = "ContactListCell"
            var cell = (tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as! BaseTableViewCell)
            // Configure the cell...
            if cell == nil {
                cell = BaseTableViewCell(style: .Default, reuseIdentifier: CellIdentifier)
            }
            return cell
        }
    }
    // Override to support conditional editing of the table view.
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        if canEditRowAtIndexPath {
            return canEditRowAtIndexPath(tableView, indexPath)
        }
        else {
            return false
        }
    }
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if heightForRowAtIndexPathCompletion {
            return heightForRowAtIndexPathCompletion(tableView, indexPath)
        }
        return 50
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return self.editingStyle
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if didSelectRowAtIndexPathCompletion {
            return didSelectRowAtIndexPathCompletion(tableView, indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if didDeselectRowAtIndexPathCompletion {
            didDeselectRowAtIndexPathCompletion(tableView, indexPath)
        }
    }
 */
}