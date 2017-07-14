//
//  EMAccountViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/7/7.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate
import MobileCoreServices
import MBProgressHUD

class EMAccountViewController: EMBaseSettingController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var myName = ""
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    lazy var imagePicker = {()-> UIImagePickerController in
        let picker = UIImagePickerController()
        picker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        picker.allowsEditing = true
        picker.delegate = self
        
        return picker
    }()
    
    lazy var signOutButton = {()-> UIButton in
        let btn = UIButton(type: UIButtonType.custom)
        btn.setTitle("Sign out", for: UIControlState.normal)
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        btn.backgroundColor = OrangeRedColor
        btn.frame = CGRect(x: 0, y: self.view.height(), width: kScreenWidth, height: 45)
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(signOut), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(signOutButton)
        let currentUser = EMClient.shared().currentUsername
        weak var weakSelf = self
        EMUserProfileManager.sharedInstance.loadUserProfileInBackground(usernames: [currentUser!], saveToLocal: true) { (success, error) in
            if error == nil && success {
                let user = EMUserProfileManager.sharedInstance.getCurUserProfile()
                weakSelf?.avatarView.imageWithUsername(username: user?.username, placeholderImage: nil)
                weakSelf?.usernameLabel.text = EMClient.shared().currentUsername
                weakSelf?.nameLabel.text = user?.nickname != nil ? user?.nickname : weakSelf?.usernameLabel.text
            }
        }
    }
    
    // MARK: - Actions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        weak var weakSelf = self
        let orgImage = info[UIImagePickerControllerOriginalImage]
        picker.dismiss(animated: true, completion: nil)
        if orgImage != nil {
            showHub(inView: view, "Uploading...")
            EMUserProfileManager.sharedInstance.uploadUserHeadImageProfileInBackground(image: (orgImage as! UIImage), complation: { (success, error) in
                weakSelf?.hideHub()
                if success {
                    weakSelf?.show("Uploaded successfully")
                } else {
                    weakSelf?.show("Upload failed")
                    let user = EMUserProfileManager.sharedInstance.getCurUserProfile()
                    weakSelf?.avatarView.imageWithUsername(username: (user?.username)!, placeholderImage: (orgImage as! UIImage))
                }
            })
            avatarView.imageWithUsername(username: nil, placeholderImage: (orgImage as! UIImage))
        } else {
            show("Upload Failed")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        weak var weakSelf = self
        if vc is EMSetNameViewController {
            (vc as! EMSetNameViewController).myName = nameLabel.text!
            (vc as! EMSetNameViewController).setup(callBack: { (nickname) in
                weakSelf?.nameLabel.text = nickname
            })
        }
    }
    
    @IBAction func EditAction(_ sender: UIButton) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        }
        
        return 55
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func signOut(_ sender: Any) {
        MBProgressHUD.showAdded(to: view, animated: true)
        weak var weakSelf = self
        EMClient.shared().logout(true) { (error) in
            MBProgressHUD.hide(for: weakSelf?.view, animated: true)
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: false))
            }else {
                weakSelf?.show("Logout failed")
            }
        }
    }
}
