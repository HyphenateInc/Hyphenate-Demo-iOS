//
//  RequestEntity.swift
//  Hyphenate Messenger
//
//  Created by Peng Wan on 10/2/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import Foundation

class RequestEntity: NSObject,NSCoding {
    var applicantUsername = ""
    var applicantNick = ""
    var reason = ""
    var receiverUsername = ""
    var receiverNick = ""
    var style: Int!
    var groupId = ""
    var groupSubject = ""
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(applicantUsername, forKey: "applicantUsername")
        aCoder.encode(applicantNick, forKey: "applicantNick")
        aCoder.encode(reason, forKey: "reason")
        aCoder.encode(receiverUsername, forKey: "receiverUsername")
        aCoder.encode(receiverNick, forKey: "receiverNick")
        aCoder.encode(style, forKey: "style")
        aCoder.encode(groupId, forKey: "groupId")
        aCoder.encode(groupSubject, forKey: "subject")
    }
    
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.applicantUsername = aDecoder.decodeObject(forKey: "applicantUsername") as! String
        self.applicantNick = aDecoder.decodeObject(forKey: "applicantNick") as! String
        self.reason = aDecoder.decodeObject(forKey: "reason") as! String
        self.receiverUsername = aDecoder.decodeObject(forKey: "receiverUsername") as! String
        self.receiverNick = aDecoder.decodeObject(forKey: "receiverNick") as! String
        self.style = aDecoder.decodeObject(forKey: "style") as! Int
        self.groupId = aDecoder.decodeObject(forKey: "groupId") as! String
        self.groupSubject = aDecoder.decodeObject(forKey: "subject") as! String
        
    }
}
