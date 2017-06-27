//
//  BaseTableViewCell.swift
//  Hyphenate Messenger
//
//  Created by Peng Wan on 9/30/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import Foundation
import UIKit



class ContactTableViewCell:UITableViewCell{

    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoView.layer.cornerRadius = 15
        photoView.clipsToBounds = true
    }
    
    class func reuseIdentifier() -> String {
        return "ContactCell"
    }
}
