//
//  EMApplyModel.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/26.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit
import Hyphenate

enum EMApplyStype {
    case contact
    case joinGroup
    case groupInvitation
}

class EMApplyModel: NSObject, NSCoding {
    var recordId: String?
    var applyHyphenateId: String?
    var applyNickName: String?
    var reason: String?
    var receiverHyphenateId: String?
    var receiverNickname: String?
    var groupId: String?
    var groupSubject: String?
    var groupMemberCount: Int = 0
    var style: EMApplyStype?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(recordId, forKey: "recordId")
        aCoder.encode(applyHyphenateId, forKey: "applyHyphenateId")
        aCoder.encode(applyNickName, forKey: "applyNickName")
        aCoder.encode(reason, forKey: "reason")
        aCoder.encode(receiverHyphenateId, forKey: "receiverHyphenateId")
        aCoder.encode(receiverNickname, forKey: "receiverNickname")
        aCoder.encode(groupId, forKey: "groupId")
        aCoder.encode(groupSubject, forKey: "groupSubject")
        aCoder.encode(groupMemberCount, forKey: "groupMemberCount")
        switch (style!) {
        case .contact: aCoder.encode(0, forKey: "style")
            break
        case .joinGroup: aCoder.encode(1, forKey: "style")
            break
        case .groupInvitation: aCoder.encode(2, forKey: "style")
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        recordId = aDecoder.decodeObject(forKey: "recordId") as? String
        applyHyphenateId = aDecoder.decodeObject(forKey: "applyHyphenateId") as? String
        applyNickName = aDecoder.decodeObject(forKey: "applyNickName") as? String
        reason = aDecoder.decodeObject(forKey: "reason") as? String
        receiverHyphenateId = aDecoder.decodeObject(forKey: "receiverHyphenateId") as? String
        receiverNickname = aDecoder.decodeObject(forKey: "receiverNickname") as? String
        groupId = aDecoder.decodeObject(forKey: "groupId") as? String
        groupSubject = aDecoder.decodeObject(forKey: "groupSubject") as? String
        if aDecoder.decodeObject(forKey: "groupMemberCount") == nil {
            groupMemberCount = 0
        }else {
            groupMemberCount = aDecoder.decodeObject(forKey: "groupMemberCount") as! Int
        }
        
        
        if aDecoder.decodeObject(forKey: "style") != nil {
            switch aDecoder.decodeObject(forKey: "style") as! Int {
            case 0:
                style = .contact
                break
            case 1:
                style = .joinGroup
                break
            case 2:
                style = .groupInvitation
                break
            default:
                break
            }
        }else {
            style = .contact
        }

    }
    
    override init() {
        super.init()
        recordId = createRecordId()
        applyHyphenateId = ""
        applyNickName = ""
        reason = ""
        receiverHyphenateId = EMClient.shared().currentUsername
        receiverNickname = EMClient.shared().currentUsername
        groupId = ""
        groupSubject = ""
        groupMemberCount = 0
        style = EMApplyStype.contact
    }
    
    func createRecordId() -> String {
        let currentTime = Date.timeIntervalBetween1970AndReferenceDate * 1000
        let randVal = arc4random() % 10000
        return "\(currentTime)" + "\(randVal)"
    }
}
