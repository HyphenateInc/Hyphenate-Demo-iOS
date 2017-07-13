//
//  AppDelegate+Parse.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/15.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Foundation
import Parse

extension AppDelegate {
    func parseApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        Parse.enableLocalDatastore()
        
        Parse.initialize(with:  ParseClientConfiguration.init { (configuration) in
            configuration.applicationId = "UUL8TxlHwKj7ZXEUr2brF3ydOxirCXdIj9LscvJs"
            configuration.clientKey = "B1jH9bmxuYyTcpoFfpeVslhmLYsytWTxqYqKQhBJ"
            configuration.server = "http://parse.easemob.com/parse/"
        })
        
        PFAnalytics .trackAppOpened(launchOptions: launchOptions)
        
        let defaultACL = PFACL()
        defaultACL.getPublicReadAccess = true
        defaultACL.getPublicWriteAccess = true
        
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
    }
    
    func initParse() {
        EMUserProfileManager.sharedInstance.intParse()
    }
    
    func clearParse() {
        EMUserProfileManager.sharedInstance.claerParse()
    }
}
