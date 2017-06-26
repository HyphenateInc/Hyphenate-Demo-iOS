//
//  EMSearchBar.swift
//  Hyphenate Messenger
//
//  Created by Peng Wan on 9/29/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import Foundation
import UIKit

class EMSearchBar:UISearchBar{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        for subView: UIView in self.subviews {
            if (subView.isKind(of: NSClassFromString("UISearchBarBackground")!)) {
                subView.removeFromSuperview()
            }
            if (subView.isKind(of: NSClassFromString("UISearchBarTextField")!)) {
                let textField = (subView as! UITextField)
                textField.borderStyle = .none
//                textField.background! = nil
                textField.frame = CGRect(x: 8, y: 8, width: self.bounds.size.width - 2 * 8, height: self.bounds.size.height - 2 * 8)
                textField.layer.cornerRadius = 6
                textField.clipsToBounds = true
                textField.backgroundColor = UIColor.white
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for subView: UIView in self.subviews {
            if (subView.isKind(of: NSClassFromString("UISearchBarBackground")!)) {
                subView.removeFromSuperview()
            }
            if (subView.isKind(of: NSClassFromString("UISearchBarTextField")!)) {
                let textField = (subView as! UITextField)
                textField.borderStyle = .none
                //                textField.background! = nil
                textField.frame = CGRect(x: 8, y: 8, width: self.bounds.size.width - 2 * 8, height: self.bounds.size.height - 2 * 8)
                textField.layer.cornerRadius = 6
                textField.clipsToBounds = true
                textField.backgroundColor = UIColor.white
            }
        }
    }
    
    func setCancelButtonTitle(_ title: String) {
        for searchbuttons: UIView in self.subviews {
            if (searchbuttons is UIButton) {
                let cancelButton = (searchbuttons as! UIButton)
                cancelButton.setTitle(title, for: UIControlState())
            }
        }
    }
}
