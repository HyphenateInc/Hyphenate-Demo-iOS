//
//  InvitationManager.swift
//  Hyphenate Messenger
//
//  Created by Peng Wan on 10/2/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import Foundation
class InvitationManager:NSObject{
    
    var sharedInstance: InvitationManager? = nil
    var defaults: UserDefaults!
        
    static let sharedInstance = InvitationManager()
    
    override init() {
        super.init()
        self.defaults = UserDefaults.standard
        
    }
        // MARK: - Data
        
        func addInvitation(_ requestEntity: RequestEntity, loginUser username: String) {
            if let defalutData = self.defaults.object(forKey: username) as? Data {
                if var requests = NSKeyedUnarchiver.unarchiveObject(with: defalutData) as? [RequestEntity]{
                    requests.append(requestEntity)
                    let data = NSKeyedArchiver.archivedData(withRootObject: requests)
                    self.defaults.set(data, forKey: username)
                }
            } else {
                let data = NSKeyedArchiver.archivedData(withRootObject: [requestEntity])
                self.defaults.set(data, forKey: username)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_requestUpdated"), object: nil)
            }
        }
    
        func removeInvitation(_ requestEntity: RequestEntity, loginUser username: String) {
            if let defalutData = self.defaults.object(forKey: username) as? Data{
                if var requests = NSKeyedUnarchiver.unarchiveObject(with: defalutData) as? [RequestEntity]{
                    var needDelete: RequestEntity?
                    for request: RequestEntity in requests {
                        if (request.groupId == requestEntity.groupId) && (request.applicantUsername == requestEntity.applicantUsername) {
                            needDelete = request
                            break
                        }
                    }
                    if let _ = needDelete{
                        if let index = requests.index(where: {$0 == needDelete!}){
                            requests.remove(at: index)
                            let data = NSKeyedArchiver.archivedData(withRootObject: requests)
                            self.defaults.set(data, forKey: username)
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "kNotification_requestUpdated"), object: nil)
                            }
                        }
                    }
                }
            }
        }
        
        func getSavedFriendRequests(_ username: String) -> [RequestEntity]? {
            if let defalutData = self.defaults.object(forKey: username) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: defalutData) as? [RequestEntity]
            }
            return nil
        }
}
