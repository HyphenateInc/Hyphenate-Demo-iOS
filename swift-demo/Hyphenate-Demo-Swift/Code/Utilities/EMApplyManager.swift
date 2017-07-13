//
//  EMApplyManager.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/27.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate

class EMApplyManager: NSObject {
    
    static let defaultManager = EMApplyManager()
    
    private let _userDefaults = UserDefaults.standard
    private var _contactApplys = Array<Any>()
    private var _groupApplys = Array<Any>()
    
    public func unHandleApplysCount() -> Int {
        return _contactApplys.count + _groupApplys.count
    }
    
    public func contactApplys() -> Array<Any>? {
        _contactApplys.removeAll()
        let contactKey = localContactApplyKey()
        if contactKey != nil {
            let contactData = _userDefaults.object(forKey: contactKey!)
            if contactData != nil {
                _contactApplys = NSKeyedUnarchiver.unarchiveObject(with: contactData as! Data) as! Array
            }
        }
        
        return _contactApplys
    }
    
    public func groupApplys() -> Array<Any>? {
        _groupApplys.removeAll()
        let groupKey = localGroupApplyKeys()
        if groupKey != nil {
            let groupData = _userDefaults.object(forKey: groupKey!)
            if groupData != nil {
                _groupApplys = NSKeyedUnarchiver.unarchiveObject(with: groupData as! Data) as! Array
            }
        }
        
        return _groupApplys
    }
    
    public func addApplyRequest(model: EMApplyModel) {
        var key = ""
        var ary = Array<Any>()
        if model.style == EMApplyStype.contact {
            key = localContactApplyKey()!
            _contactApplys.append(model)
            ary = _contactApplys
        }else {
            key = localGroupApplyKeys()!
            _groupApplys.append(model)
            ary = _groupApplys
        }
        if key.characters.count == 0 {
            return
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: (ary as NSArray))
        _userDefaults.set(data, forKey: key)
    }
    
    public func removeApplyRequest(model: EMApplyModel) {
        var key = ""
        var ary = Array<Any>()
        if model.style == EMApplyStype.contact {
            key = localContactApplyKey()!
            ary = _contactApplys
        }else {
            key = localGroupApplyKeys()!
            ary = _groupApplys
        }
        if key.characters.count == 0 {
            return
        }
        
        var index = -1
        for (idx, obj) in ary.enumerated() {
            if obj is EMApplyModel {
                let model = obj as! EMApplyModel
                if model.recordId == model.recordId {
                    index = idx
                    break
                }
            }
        }
        if index >= 0 && ary.count > index{
            ary.remove(at: index)
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: ary)
        _userDefaults.set(data, forKey: key)
        
        loadAllApplys()
    }
    
    public func isExisting(request applyHyphenateId: String, _ groupid: String?, _ applyStyle: EMApplyStype) -> Bool{
        var sources: Array<Any>?
        var ret = false
        if applyStyle == EMApplyStype.contact {
            sources = contactApplys()
        }else {
            if groupid == nil {
                return true
            }
            sources = groupApplys()
        }
        
        if sources != nil && sources!.count > 0 {
            for (_, obj) in sources!.enumerated() {
                if obj is EMApplyModel {
                    let model = obj as! EMApplyModel
                    if model.applyHyphenateId == applyHyphenateId && model.style == applyStyle {
                        if applyStyle == EMApplyStype.contact || (applyStyle != EMApplyStype.contact && model.groupId == groupid){
                            ret = true
                            break
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    override init() {
        super.init()
        loadAllApplys()
    }
    
    func loadAllApplys() {
        let contactKey = localContactApplyKey()
        if contactKey != nil {
            let contactData = _userDefaults.object(forKey: contactKey!)
            if contactData != nil {
                _contactApplys = NSKeyedUnarchiver.unarchiveObject(with: contactData as! Data) as! Array
            }
        }
        
        let groupKey = localGroupApplyKeys()
        if groupKey != nil {
            let groupData = _userDefaults.object(forKey: groupKey!)
            if groupData != nil {
                _groupApplys = NSKeyedUnarchiver.unarchiveObject(with: groupData as! Data) as! Array
            }
        }
    }
    
    func localContactApplyKey() -> String? {
        let loginCount = EMClient.shared().currentUsername
        if loginCount == nil {
            return nil
        }
        
        return loginCount! + "_contactApplys"
    }
    
    func localGroupApplyKeys() -> String? {
        let loginCount = EMClient.shared().currentUsername
        if loginCount == nil {
            return nil
        }
        
        return loginCount! + "_groupApplys"
    }
}
