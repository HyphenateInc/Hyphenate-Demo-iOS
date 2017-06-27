//
//  FriendRequestTableViewCell.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 10/3/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
    }

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var request: RequestEntity!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func reuseIdentifier() -> String {
        return "FriendRequestCell"
    }
    
    @IBAction func declineAction(_ sender: AnyObject) {
        spinner.startAnimating()
        EMClient.shared().contactManager.declineFriendRequest(fromUser: usernameLabel.text) { (userName, error) in
            self.spinner.stopAnimating()
            if error != nil {
                let alert = UIAlertController(title:"Error", message: "Fail declining a friend request, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                InvitationManager.sharedInstance.removeInvitation(self.request, loginUser: EMClient.shared().currentUsername)
            }
        }
    }
    
    @IBAction func acceptAction(_ sender: AnyObject) {
        spinner.startAnimating()
        EMClient.shared().contactManager.approveFriendRequest(fromUser: usernameLabel.text) { (userName, error) in
            self.spinner.stopAnimating()
            if error != nil {
                let alert = UIAlertController(title:"Error", message: "Fail accepting a friend request, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                InvitationManager.sharedInstance.removeInvitation(self.request, loginUser: EMClient.shared().currentUsername)
            }
        }
    }
}
