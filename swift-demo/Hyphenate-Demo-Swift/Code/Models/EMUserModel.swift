//
//  EMUserModel.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/26.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit

protocol IEMUserModel {
    var hyphenateID: String? {get set}
    var nickname: String? {get}
    var avatarURLPath: String? {get}
    var defaultAvatarImage: UIImage? {get}
    
    static func createWithHyphenateId(hyphenateId: String) -> IEMUserModel?
}

class EMUserModel: NSObject, IEMUserModel, EMRealtimeSearchUtilDelegate{

    var _hyphenateID: String?
    
    var hyphenateID: String? {
        get {
            return _hyphenateID
        }
        
        set {
            _hyphenateID = newValue
        }
    }
    
    var nickname: String? {
        get {
            let nickname = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: hyphenateID!)
            if nickname.characters.count > 0 {
                return nickname
            }
            return hyphenateID
        }
    }
    
    var avatarURLPath: String? {
        get {
            let userEntity = EMUserProfileManager.sharedInstance.getUserProfileByUsername(username: hyphenateID!)
            if userEntity != nil && userEntity?.imageUrl != nil {
               return (userEntity?.imageUrl)!
            }

            return nil
        }
    }
    
    var defaultAvatarImage: UIImage? {
        get {
            return UIImage(named:"default_avatar")
        }
    }
    
    static func createWithHyphenateId(hyphenateId: String) -> IEMUserModel? {
        let userModel = EMUserModel()
        userModel.hyphenateID = hyphenateId
        return userModel
    }
    
    // MARK: - EMRealtimeSearchUtilDelegate
    func searchKey() -> String? {
        return nickname
    }
}
