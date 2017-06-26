//
//  ConversationTableViewCell.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/1/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
//    @IBOutlet weak var badgeView: M13BadgeView!
    
    @IBOutlet weak var badgeView: M13BadgeView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        senderImageView.layer.cornerRadius = 25.0
        senderImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
