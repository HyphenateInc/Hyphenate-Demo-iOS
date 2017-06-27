//
//  ProfileSwitchTableViewCell.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/2/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class ProfileSwitchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var title: UILabel!
   
    @IBOutlet weak var switchControl: UISwitch!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func reuseIdentifier() -> String {
        return "profileSwitchCell"
    }

    
}
