//
//  NSObject+EMAlertView.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/27.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    @nonobjc
    func showAlert(_ message: String){
        showAlert(message, nil)
    }
    
    @nonobjc
    func showAlert(_ message: String, _ delegate: UIAlertViewDelegate?) {
        showAlert(nil, message, delegate)
    }
 
    @nonobjc
    func showAlert(_ title: String, _ message: String) {
        showAlert(title, message, nil)
    }
    
    @nonobjc
    func showAlert(_ title: String?, _ message: String, _ delegate: UIAlertViewDelegate?){
        let alertView = UIAlertView.init(title: title, message: message, delegate: delegate, cancelButtonTitle: "OK")
        alertView.show()
    }
}
