//
//  EMUserProfileManager.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/15.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Parse
import Hyphenate

let kPARSE_HXUSER = "hxuser"
//let kPARSE_HXUSER = "HyphenateUser"
let kPARSE_HXUSER_USERNAME = "username"
let kPARSE_HXUSER_NICKNAME = "nickname"
let kPARSE_HXUSER_AVATAR = "avatar"



extension UIImage {
    func imageByScalingAndCroppingForSize(targetSize:CGSize) -> UIImage {
        let sourceImage = self
        var newImage : UIImage? = nil
        let imageSize = sourceImage.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height
        var scaleFactor = 0.0
        var scaleWidth = targetWidth
        var scaleHeight = targetHeight
        var thumbnailPoint = CGPoint(x: 0, y: 0 )
        
        if imageSize != targetSize {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = Double(widthFactor)
            } else {
                scaleFactor = Double(heightFactor)
            }
            
            scaleWidth = CGFloat(Double(width) * scaleFactor)
            scaleHeight = CGFloat(Double(height) * scaleFactor)
            
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaleHeight) * 0.5
            } else {
                thumbnailPoint.x = (targetWidth - scaleWidth) * 0.5
            }
        }
        
        UIGraphicsBeginImageContext(targetSize)
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaleWidth
        thumbnailRect.size.height = scaleHeight
        sourceImage.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

class UserProfileEntity: NSObject {
    
    var objectId:String?
    var username:String?
    var nickname:String?
    var imageUrl:String?
    
    override init() {
        super.init()
    }
    
    class func initPFObject(PFObject object: PFObject) -> UserProfileEntity{
        
        let entity = UserProfileEntity()
        entity.username = object[kPARSE_HXUSER_USERNAME] as? String
        entity.nickname = object[kPARSE_HXUSER_NICKNAME] as? String
        let useranmeImage = object[kPARSE_HXUSER_AVATAR] as? PFFile
        if useranmeImage != nil {
            entity.imageUrl = useranmeImage?.url
        }
        
        return entity
    }
}

class EMUserProfileManager: NSObject {
    
    private var _currentName : String?
    
    var users = Dictionary<String, UserProfileEntity>()
    var objectId : String?
    var defaultACL: PFACL?
    
    static let sharedInstance = EMUserProfileManager()
    
    override init() {
        super.init()
        defaultACL = PFACL()
        defaultACL?.getPublicReadAccess = true
        defaultACL?.getPublicWriteAccess = true
    }
    
    func intParse() {
        let userDefault = UserDefaults.standard
        let objId : String? = userDefault.object(forKey: kPARSE_HXUSER + EMClient.shared().currentUsername) as? String
        if objId != nil {
            self.objectId = objId
        }
        
        _currentName = EMClient.shared().currentUsername
        initData()
    }
    
    func claerParse() {
        objectId = nil
        let userDefault = UserDefaults.standard
        if _currentName != nil {
            userDefault.removeObject(forKey: kPARSE_HXUSER + _currentName!)
            _currentName = nil
        }
        
        users.removeAll()
    }
    
    func initData() {
        users.removeAll()
        let query = PFQuery.init(className: kPARSE_HXUSER)
        query.findObjectsInBackground { (objects, error) in
            if objects != nil && objects!.count > 0 {
                for user in objects! {
                    let entity = UserProfileEntity.initPFObject(PFObject: user)
                    if (entity.username?.characters.count)! > 0 {
                        user.setObject(entity, forKey: entity.username!)
                    }
                }
            }
        }
    }
    
    func uploadUserHeadImageProfileInBackground(image: UIImage, complation:@escaping (Bool, Error?) -> Void) {
        weak var weakSelf = self
        let img = image.imageByScalingAndCroppingForSize(targetSize: CGSize.init(width: 120, height: 120))
        if objectId != nil && (objectId?.characters.count)! > 0 {
            let object = PFObject(withoutDataWithClassName: kPARSE_HXUSER, objectId: objectId)
            DispatchQueue.global().async {
                do{ try object.fetchIfNeeded() } catch {}
            }
            
            let data = UIImageJPEGRepresentation(img, 0.5)
            let imageFile = PFFile.init(name: "image.png", data: data!)
            object[kPARSE_HXUSER_AVATAR] = imageFile
            object.saveInBackground(block: { (successed, error) in
                if successed {
                    weakSelf?.savePFUserInDisk(obj: object)
                }
                complation(successed, error)
            })
        } else {
            queryPFObject(complation: { (object, error) in
                if object != nil {
                    let data = UIImageJPEGRepresentation(img, 0.5)
                    let imageFile = PFFile.init(name: "image.png", data: data!)
                    object?[kPARSE_HXUSER_AVATAR] = imageFile
                    object!.saveInBackground(block: { (successed, error) in
                        if successed {
                            weakSelf?.savePFUserInDisk(obj: object)
                        }
                        complation(successed, error)
                    })
                }else {
                    complation(false, error)
                }
            })
        }
    }
    
    func updateUserProfileInBackground(param:Dictionary<String, Any>?, complation:@escaping (Bool, Error?) -> Void) {
        weak var weakSelf = self
        if objectId != nil && (objectId?.characters.count)! > 0 {
            let object = PFObject(withoutDataWithClassName: kPARSE_HXUSER, objectId: objectId)
            DispatchQueue.global().async {
                do{ try object.fetchIfNeeded() } catch {}
            }
            
            if param != nil && (param?.keys.count)! > 0 {
                for key in (param?.keys)! {
                    object.setObject(param?[key]! as Any, forKey: key)
                }
            }
            
            weak var uObject = object
            object.saveInBackground(block: { (successed, error) in
                if successed {
                    weakSelf?.savePFUserInDisk(obj: uObject)
                }
                complation(successed, error)
            })
        } else {
            queryPFObject(complation: { (object, error) in
                if object != nil {
                    if param != nil && (param?.keys.count)! > 0 {
                        for key in (param?.keys)! {
                            object?.setObject(param?[key]! as Any, forKey: key)
                        }
                    }
                    
                    weak var uObject = object!
                    object!.saveInBackground(block: { (successed, error) in
                        if successed {
                            weakSelf?.savePFUserInDisk(obj: uObject)
                        }
                        complation(successed, error)
                    })
                }else {
                    complation(false, error)
                }
            })
        }
    }
    
    func loadUserProfileInBackgroundWithBuddy(buddyList:Array<String>, saveToLocat save:Bool, complation:@escaping (Bool, Error?)->Void) {
        var usernames = Array<String>()
        for buddyName in buddyList {
            if  buddyName.characters.count > 0 {
                if getUserProfileByUsername(username: buddyName) == nil {
                    usernames.append(buddyName)
                }
            }
        }
        
        if usernames.count == 0 {
            complation(true, nil)
            return
        }
        
        loadUserProfileInBackground(usernames: usernames, saveToLocal: save, complation: complation)
    }
    
    func loadUserProfileInBackground(usernames:Array<String>, saveToLocal save:Bool, complation:@escaping (Bool, Error?)->Void) {
        weak var weakSelf = self
        let query = PFQuery.init(className: kPARSE_HXUSER)
        query.whereKey(kPARSE_HXUSER_USERNAME, containedIn: usernames)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for user in objects! {
                    let pfUser = user as PFObject
                    if save {
                        weakSelf?.savePFUserInDisk(obj: pfUser)
                    } else {
                        weakSelf?.savePFUserInMemory(obj: pfUser)
                    }
                }
                complation(true, nil)
            } else {
                complation(false, error)
            }
        }
    }
    
    func getUserProfileByUsername(username:String?) -> UserProfileEntity? {
        if  username != nil {
            if users[username!] != nil {
                return users[username!]
            }
        }
        return nil
    }
    
    func getCurUserProfile() -> UserProfileEntity? {
        return getUserProfileByUsername(username: EMClient.shared().currentUsername)
    }
    
    func getNickNameWithUsername(username:String) -> String {
        let entity = getUserProfileByUsername(username: username)
        if entity?.nickname != nil && (entity?.nickname?.characters.count)! > 0 {
            return (entity?.nickname)!
        }
        
        return username
    }
    
    // MARK: - Private
    func savePFUserInDisk(obj: PFObject?) {
        if obj != nil {
            obj!.pinInBackground(withName: EMClient.shared().currentUsername)
            savePFUserInMemory(obj: obj!)
        }
    }
    
    func savePFUserInMemory(obj: PFObject) {
        let entity = UserProfileEntity.initPFObject(PFObject: obj)
        users[entity.username!] = entity
    }
    
    func queryPFObject(complation:@escaping (PFObject?, Error?) -> Void) {
        let query = PFQuery.init(className: kPARSE_HXUSER)
        query.whereKey(kPARSE_HXUSER_USERNAME, equalTo: EMClient.shared().currentUsername)
        weak var weakSelf = self
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                if objects != nil && (objects?.count)! > 0 {
                    let object = objects![0] as PFObject
                    object.acl = weakSelf?.defaultACL
                    let userDefault = UserDefaults.standard
                    userDefault.set(object.objectId, forKey: kPARSE_HXUSER+EMClient.shared().currentUsername)
                    userDefault.synchronize()
                    complation(object, error)
                }
            }else {
                complation(nil,error)
            }
        }
    }
}

